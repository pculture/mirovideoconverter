/* -*- mode: objc -*- */
//
//  Created by C Worth on 2/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CWTask.h"
#import <Cocoa/Cocoa.h>

@implementation CWTask
@synthesize task,delegate,tellDelegateTaskEndedDelayTimer;

- (id)init {
  self = [super init];
  return self;
}
- (int) startTask:(NSString *)path withArgs:(NSArray *)args {
  task = [[NSTask alloc] init];

  [task setLaunchPath:path];
  [task setArguments:args];

  [[NSNotificationCenter defaultCenter]
    addObserver:self selector:@selector(taskEnded:)
    name:NSTaskDidTerminateNotification object:task];

  [task setStandardOutput:[NSPipe pipe]];
  [task setStandardError: [NSPipe pipe]];

  [[NSNotificationCenter defaultCenter]
    addObserver:self selector:@selector(taskUpdateStdOut:)
    name:NSFileHandleReadCompletionNotification
    object:[[task standardOutput]fileHandleForReading]];
  [[NSNotificationCenter defaultCenter]
    addObserver:self selector:@selector(taskUpdateStdErr:)
    name:NSFileHandleReadCompletionNotification
    object:[[task standardError] fileHandleForReading]];

  [task launch];

  [[[task standardOutput] fileHandleForReading] readInBackgroundAndNotify];
  [[[task standardError] fileHandleForReading] readInBackgroundAndNotify];

  return [task processIdentifier];
}
- (void) taskUpdateStdOut:(NSNotification *)note {
  [self taskUpdateStream:@"stdout" withNote:note];
}
- (void) taskUpdateStdErr:(NSNotification *)note {
  [self taskUpdateStream:@"stderr" withNote:note];
}
- (void) taskUpdateStream:(NSString *)stream withNote:(NSNotification *)note {
  NSData *data = [[note userInfo] objectForKey:NSFileHandleNotificationDataItem];
  if([data length] > 0) {
    NSString *string = [NSString stringWithUTF8String:[data bytes]];
    NSDictionary *dict = [NSDictionary dictionaryWithObject:string forKey:stream];
    [delegate cwTask:self update:dict];
    [(NSFileHandle *)[note object] readInBackgroundAndNotify];
  } else
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                          name:NSFileHandleReadCompletionNotification
                                          object:[note object]];
}

- (void) taskEnded:(NSNotification *)note {
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                        name:NSTaskDidTerminateNotification object:nil];
  taskReturnValue = [[note object] terminationStatus];
  self.tellDelegateTaskEndedDelayTimer = 
    [NSTimer scheduledTimerWithTimeInterval:0.4 target:self
             selector:@selector(tellDelegateTaskEnded:)
             userInfo:nil
             repeats:NO];
}

- (void) tellDelegateTaskEnded:(NSTimer *)timer {
  self.tellDelegateTaskEndedDelayTimer = nil;
  [delegate cwTask:self ended:taskReturnValue];
}

- (void) endTask {
  if([task isRunning])
    [task terminate];
}

@end
