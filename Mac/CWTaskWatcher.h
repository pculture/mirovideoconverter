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

@interface CWTaskWatcher : NSObject <CWTaskDelegate> {
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
- (void) requestFinishWithStatus:(TaskEndStatus)status;
- (void) killProcess;
- (void) finish;
- (void) watchTask:(NSTimer *)timer;
- (void) updateFileInfo;

@end

@protocol CWTaskWatcherDelegate
- (void)cwTaskWatcher:(CWTaskWatcher *)cwTaskWatcher updateString:(NSString *)output;
- (void)cwTaskWatcher:(CWTaskWatcher *)cwTaskWatcher updateFileInfo:(NSDictionary *)dict;
- (void)cwTaskWatcher:(CWTaskWatcher *)cwTaskWatcher ended:(TaskEndStatus)status;
@optional
- (NSString *)cwTaskWatcher:(CWTaskWatcher *)cwTaskWatcher censorOutput:(NSString *)input;
@end
