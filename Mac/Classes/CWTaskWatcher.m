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

@implementation CWTaskWatcher
@synthesize task,pid,delegate,textStorage,loopTimer,progressFile,taskStartDate,taskEndRequestDate;

- (id)init {
  self = [super init];
  task = [[CWTask alloc] init];
  task.delegate = self;
  runStatus = RunStatusNone;
  endStatus = EndStatusNone;
  return self;
}
- (void) startTask:(NSString *)path withArgs:(NSArray *)args {
  [self startTask:path withArgs:args andProgressFile:nil];
}
- (void) startTask:(NSString *)path withArgs:(NSArray *)args
    andProgressFile:(NSString *)file {
  if(runStatus == RunStatusNone){
    runStatus = RunStatusRunning;
    endStatus = EndStatusNone;
    self.progressFile = file;
    if([[NSFileManager defaultManager] isReadableFileAtPath:file])
      [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
    self.pid = [task startTask:path withArgs:args];
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
  int filesize = 0;
  if(progressFile && ![[NSFileManager defaultManager] isReadableFileAtPath:progressFile])
    filesize = (int) [[[NSFileManager defaultManager]
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
  [delegate cwTaskWatcher:self updateFileInfo:dict];
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
          [delegate cwTaskWatcher:self updateString:newOutput];
        }
      }
    }
  }
}
@end

//                       withString:[NSString stringWithFormat:@"%@:%@",
//                                            arg, newOutput]];

//-(void) monitorSpeedTest:(NSTimer *)timer {
//  static int oldSize = 0;
//
//  int fileSize = 0;
//  EndSpeedTest endTest = WAITING;
//  if(![conversionTask isRunning])
//    endTest = TASKDONE;   // task ended
//  else {
//    NSString *outputFile = [self fFMPEGOutputFile:speedFile];
//    if (![[NSFileManager defaultManager] isReadableFileAtPath:outputFile]) {
//      if([conversionTime timeIntervalSinceNow]*(-1) > 3.0)
//        endTest = ERROR; // file not created for 3 sec after start
//    } else {
//      fileSize = (int) [[[NSFileManager defaultManager]
//                          attributesOfItemAtPath:outputFile error:nil]
//                         fileSize];
//      if(oldSize && fileSize == oldSize &&
//         [conversionTime timeIntervalSinceNow]*(-1) > 3.0)
//        endTest = ERROR; // file hung for 3 sec since last update
//    }
//  }
//
//  if(endTest == WAITING){
//    if(oldSize != fileSize){
//      oldSize = fileSize;
//      self.conversionTime = [NSDate date];
//    }
//  } else {
//    [timer invalidate];
//    oldSize = 0;
//    [self speedTestCompleted:endTest];
//  }
//  }
