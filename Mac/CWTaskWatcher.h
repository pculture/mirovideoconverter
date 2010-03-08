/* -*- mode: objc -*- */
//
//  Created by C Worth on 2/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CWTask.h"
#define TIMEOUT_INTERVAL 3

typedef enum { RunStatusNone, RunStatusRunning, RunStatusEndRequested, RunStatusKillRequested, RunStatusTaskEnded } TaskRunStatus;
typedef enum { EndStatusNone, EndStatusOK, EndStatusError, EndStatusCancel } TaskEndStatus;

@interface CWTaskWatcher : NSObject <CWTaskDelegate>{
  TaskRunStatus runStatus;
  TaskEndStatus endStatus;
  CWTask *task;
  int pid;
  id delegate;
  NSTextStorage *textStorage;
  NSTimer *loopTimer;
  NSString *progressFile;
  NSDate *taskStartDate;
  NSDate *taskEndRequestDate;
}
@property(retain) CWTask *task;
@property(assign) int pid;
@property(assign) id delegate;
@property(assign) NSTextStorage *textStorage;
@property(retain) NSTimer *loopTimer;
@property(retain) NSString *progressFile;
@property(retain) NSDate *taskStartDate;
@property(retain) NSDate *taskEndRequestDate;

- (void) startTask:(NSString *)path withArgs:(NSArray *)args
   andProgressFile:(NSString *)file;
- (void) startTask:(NSString *)path withArgs:(NSArray *)args;
- (void) finish;
- (void) watchTask:(NSTimer *)timer;
- (void) updateFileInfo;
- (void) requestFinishWithStatus:(TaskEndStatus)status;
- (void) killProcess;
@end

@protocol CWTaskWatcherDelegate
- (void)cwTaskWatcher:(CWTaskWatcher *)cwTaskWatcher updateString:(NSString *)output;
- (void)cwTaskWatcher:(CWTaskWatcher *)cwTaskWatcher updateFileInfo:(NSDictionary *)dict;
- (void)cwTaskWatcher:(CWTaskWatcher *)cwTaskWatcher ended:(TaskEndStatus)status;
@end
