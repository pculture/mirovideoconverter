/* -*- mode: objc -*- */
//
//  Created by C Worth on 2/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CWTaskWatcher.h"
#import <Cocoa/Cocoa.h>

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
      [NSTimer scheduledTimerWithTimeInterval:0.3 target:self
               selector:@selector(watchTask:)
               userInfo:nil
               repeats:YES];
  }
}
- (void) finish {
  if([loopTimer isValid])
    [loopTimer invalidate];
  [self updateFileInfo];
  if(progressFile && (endStatus == EndStatusError || endStatus == EndStatusCancel))
    if([[NSFileManager defaultManager] isReadableFileAtPath:progressFile])
      [[NSFileManager defaultManager] removeItemAtPath:progressFile error:nil];
  [delegate cwTaskWatcher:self ended:endStatus];
  self.task = 0;
  self.loopTimer = 0;
  self.progressFile = 0;
  self.taskEndRequestDate = 0;
}
-(void) watchTask:(NSTimer *)timer {
  int i=1; i=2;
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
- (void) requestFinishWithStatus:(TaskEndStatus)status {
  if(runStatus == RunStatusRunning){
    runStatus = RunStatusEndRequested;
    endStatus = status;
    [task endTask];
    self.taskEndRequestDate = [NSDate date];
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
          newOutput = [NSString stringWithString:tmpOutput];
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
-(void) killProcess {
  CWTask *killTask = [[CWTask alloc] init];
  [task startTask:@"/bin/sh"
        withArgs:[NSArray arrayWithObjects:
                            @"-c",
                          [NSString stringWithFormat:@"kill -9 %i", pid],
                          nil]];
  [killTask release];
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
