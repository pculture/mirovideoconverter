/* -*- mode: objc -*- */
//
//  Created by C Worth on 2/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CWTask : NSObject {
  NSTask *task;
  id delegate;
  int taskReturnValue;
  NSTimer *tellDelegateTaskEndedDelayTimer;
}
@property(assign) NSTask *task;
@property(assign) id delegate;
@property(retain) NSTimer *tellDelegateTaskEndedDelayTimer;

- (int) startTask:(NSString *)path withArgs:(NSArray *)args;
- (void) taskUpdateStdOut:(NSNotification *)note;
- (void) taskUpdateStdErr:(NSNotification *)note;
- (void) taskUpdateStream:(NSString *)stream withNote:(NSNotification *)note;
- (void) taskEnded:(NSNotification *)note;
- (void) tellDelegateTaskEnded:(NSTimer *)timer;
- (void) endTask;
@end

@protocol CWTaskDelegate
- (void) cwTask:(CWTask *)cwtask update:(NSDictionary *)info;
- (void) cwTask:(CWTask *)cwtask ended:(int)returnValue;
@end
