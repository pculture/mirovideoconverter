//  MiroVideoConverter -- a super simple way to convert almost any video to MP4, 
//  Ogg Theora, or a specific phone or iPod.
//
//  Copyright 2010 Participatory Culture Foundation
//
//  This file is part of MiroVideoConverter.
//
//  MiroVideoConverter is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  MiroVideoConverter is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with MiroVideoConverter.  If not, see http://www.gnu.org/licenses/.
//
//  Created by C Worth on 2/18/10.
//

#import "CWTaskWatcher.h"
#import <Cocoa/Cocoa.h>

#define WATCH_INTERVAL 0.3
#define STARTUP_IDLE_TIME 4
/**
// CWTaskWatcher
//
// Call startTask to start an asynchronous command with arguments and
// optionally specify a progress file whose size
// is "watched" while the task runs. Set the delegate, optional textStorage
// that holds stdout/stdin output, and optional endIdleInterval after which,
// if the progress file is hung, the task will be cancelled.
// Call requestFinishWithStatus to terminate task and return particular status
// to delegate.
// The optional delegate function cwTaskWatcher:updateString: relays output from
// the task to the delegate.  If textStorage is non-nil, the output is also
// appended to an NSTextStorage object.  Output can be modified before it is
// processed by implementing the delegate function cwTask:censorOutput:.
// CWTaskWatcher runs the function watchTask on a loop several times a second
// that manages the runState of the task. This has several functions:
// 1) When a cancel request is received, a request is made to the task. If the
//    task does not respond after a specified time interval, a kill command is 
//    run on the pid of the task.  If the task does not terminate after another
//    interval, the state is set to done anyway.
// 2) While the task is running and a cancel request has not been received, the optional
      delegate function cwTaskWatcher:updateFileInfo: is called with a dictionary
      containing the progress file size and the amount of time the task has been
      running.  If endIdleInterval is set and the file size has remained constant
      for more than the specified interval, the task sends itself a cancellation request.
*/

@implementation CWTaskWatcher
@synthesize delegate,textStorage,endIdleInterval,task,pid,loopTimer,progressFile,taskStartDate,taskEndRequestDate;
@synthesize lastFileSizeTime;
- (id)init {
  self = [super init];
  task = [[CWTask alloc] init];
  task.delegate = self;
  runStatus = RunStatusNone;
  endStatus = EndStatusNone;
  return self;
}
- (void) startTask:(NSString *)path withArgs:(NSArray *)args {
  [self startTask:path withArgs:args andProgressFile:nil addToEnvironment:nil];
}
- (void) startTask:(NSString *)path withArgs:(NSArray *)args
    andProgressFile:(NSString *)file {
  [self startTask:path withArgs:args andProgressFile:file addToEnvironment:nil];
}
- (void) startTask:(NSString *)path withArgs:(NSArray *)args
  addToEnvironment:(NSDictionary *)addedEnv {
  [self startTask:path withArgs:args andProgressFile:nil addToEnvironment:addedEnv];
}
- (void) startTask:(NSString *)path withArgs:(NSArray *)args
    andProgressFile:(NSString *)file
  addToEnvironment:(NSDictionary *)addedEnv {
  if(runStatus == RunStatusNone){
    runStatus = RunStatusRunning;
    endStatus = EndStatusNone;
    self.progressFile = file;
    if(file && [[NSFileManager defaultManager] isReadableFileAtPath:file])
      [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
    self.pid = [task startTask:path withArgs:args addToEnvironment:addedEnv];
    self.taskStartDate = [NSDate date];
    self.loopTimer = 
      [NSTimer scheduledTimerWithTimeInterval:WATCH_INTERVAL target:self
               selector:@selector(watchTask:)
               userInfo:nil
               repeats:YES];
  }
}

- (void) requestFinishWithStatus:(TaskEndStatus)status {
  if(runStatus == RunStatusRunning){
    runStatus = RunStatusEndRequested;
    endStatus = status;
    self.taskEndRequestDate = [NSDate date];
    [task endTask];
  }
}
-(void) killProcess {
  CWTask *killTask = [[CWTask alloc] init];
  [task startTask:@"/bin/sh"
        withArgs:[NSArray arrayWithObjects:
                            @"-c",
                          [NSString stringWithFormat:@"kill -9 %i", pid],
                          nil]];
  [killTask release];
}

- (void) finish {
  if([loopTimer isValid])
    [loopTimer invalidate];
  [self updateFileInfo];
  [delegate cwTaskWatcher:self ended:endStatus];
  self.task = 0;
  self.loopTimer = 0;
  self.progressFile = 0;
  self.taskEndRequestDate = 0;
}
-(void) watchTask:(NSTimer *)timer {
  switch(runStatus){
  case RunStatusNone:
    break;
  case RunStatusRunning:
    [self updateFileInfo];
    break;
  case RunStatusEndRequested:
    if([self.taskEndRequestDate timeIntervalSinceNow]*(-1) >
       TIMEOUT_INTERVAL) {
      runStatus = RunStatusKillRequested;
      self.taskEndRequestDate = [NSDate date];
      [self killProcess];
    }
    break;
  case RunStatusKillRequested:
    if([self.taskEndRequestDate timeIntervalSinceNow]*(-1) >
       TIMEOUT_INTERVAL) {
      runStatus = RunStatusTaskEnded;
    }
    break;
  case RunStatusTaskEnded:
    [self finish];
    runStatus = RunStatusNone;
    endStatus = EndStatusNone;
    break;
  }
}
- (void) updateFileInfo {
  if(runStatus == RunStatusRunning && progressFile &&
     [[NSFileManager defaultManager] isReadableFileAtPath:progressFile]) {
    int filesize = (int) [[[NSFileManager defaultManager]
                          attributesOfItemAtPath:progressFile error:nil]
                         fileSize];
    int time = [taskStartDate timeIntervalSinceNow] * -1;
    NSDictionary *dict =
      [NSDictionary dictionaryWithObjects:
                [NSArray arrayWithObjects:
                           [NSNumber numberWithFloat:(float)time],
                  [NSNumber numberWithInt:filesize],nil]
                                  forKeys:
                [NSArray arrayWithObjects:
                           @"elapsedTime",@"filesize",nil]];
    if([delegate respondsToSelector:@selector(cwTaskWatcher:updateFileInfo:)])
      [delegate cwTaskWatcher:self updateFileInfo:dict];
    // If endIdleInterval is set and file is hung, requestFinish with error
    if(endIdleInterval && time > STARTUP_IDLE_TIME) {
      if(!lastFileSizeTime) {
        lastFileSize = filesize;
        self.lastFileSizeTime = [NSDate date];
      } else {
        if(lastFileSize == filesize) {
          if([lastFileSizeTime timeIntervalSinceNow]*(-1) > endIdleInterval)
            [self requestFinishWithStatus:EndStatusError]; // changes runState so this
        } else {                                           // won't get called again
          lastFileSize = filesize;
          self.lastFileSizeTime = [NSDate date];
        }
      }
    } else {
      lastFileSizeTime = nil;
    }
  }
}
- (void)cwTask:(CWTask *)cwtask ended:(int)returnValue{
  switch(runStatus) {
  case RunStatusNone:
    break;
  case RunStatusRunning:
    runStatus = RunStatusTaskEnded;
    endStatus = (returnValue == 0 ? EndStatusOK : EndStatusError);
    break;
  case RunStatusEndRequested:
    runStatus = RunStatusTaskEnded;
    break;
  case RunStatusKillRequested:
    runStatus = RunStatusTaskEnded;
    break;
  case RunStatusTaskEnded:
    break;
  }
}
- (void)cwTask:(CWTask *)cwtask update:(NSDictionary *)info{
  if(runStatus == RunStatusRunning || runStatus == RunStatusEndRequested){
    for(NSString *arg in [NSArray arrayWithObjects:@"stdout",@"stderr",nil]){
      NSString *tmpOutput = [info objectForKey:arg];
      NSString *newOutput;
      if(tmpOutput){
        if([delegate respondsToSelector:@selector(cwTaskWatcher:censorOutput:)])
          newOutput = [delegate cwTaskWatcher:self censorOutput:tmpOutput];
        else
          newOutput = tmpOutput;
        if(newOutput){
          if(textStorage)
            [textStorage replaceCharactersInRange:NSMakeRange([textStorage length], 0)
                         withString:newOutput];
          if([delegate respondsToSelector:@selector(cwTaskWatcher:updateString:)])
            [delegate cwTaskWatcher:self updateString:newOutput];
        }
      }
    }
  }
}
@end
