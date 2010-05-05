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

#import "CWTask.h"
#import <Cocoa/Cocoa.h>

#define DELAY_BEFORE_NOTIFY_ENDED 0.4

/////////////////////////////////
@interface CWTask (Private)
+ (NSString *) stringWithCleanedUpUTF8String:(char *)input length:(int)length;
- (void) taskUpdateStdOut:(NSNotification *)note;
- (void) taskUpdateStdErr:(NSNotification *)note;
- (void) taskUpdateStream:(NSString *)stream withNote:(NSNotification *)note;
- (void) taskEnded:(NSNotification *)note;
- (void) tellDelegateTaskEnded:(NSTimer *)timer;
@end
/////////////////////////////////

@implementation CWTask (Private)
+ (NSString *) stringWithCleanedUpUTF8String:(char *)input length:(int)length{
  char *buf = malloc(length+1);
  strncpy(buf,input,length);
  buf[length] = 0;
  for(int i=0; i<length; i++)
    if((unsigned char)buf[i] > 127) buf[i] = ' ';
  NSString *output = [NSString stringWithUTF8String:(char *)buf];
  free(buf);
  return output;
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
    NSString *string = [CWTask stringWithCleanedUpUTF8String:(char *)[data bytes] length:[data length]];
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
    [NSTimer scheduledTimerWithTimeInterval:DELAY_BEFORE_NOTIFY_ENDED target:self
             selector:@selector(tellDelegateTaskEnded:)
             userInfo:nil
             repeats:NO];
}

- (void) tellDelegateTaskEnded:(NSTimer *)timer {
  self.tellDelegateTaskEndedDelayTimer = nil;
  [delegate cwTask:self ended:taskReturnValue];
}

@end

@implementation CWTask
@synthesize task,delegate,tellDelegateTaskEndedDelayTimer;

- (int) startTask:(NSString *)path withArgs:(NSArray *)args {
  task = [[NSTask alloc] init];

  [task setLaunchPath:path];
  [task setArguments:args];

  [[NSNotificationCenter defaultCenter]
    addObserver:self selector:@selector(taskEnded:)
    name:NSTaskDidTerminateNotification object:task];

  [task setStandardInput:[NSPipe pipe]];
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

- (void) endTask {
  if([task isRunning])
    [task terminate];
}

+ (NSString *) performSynchronousTask:(NSString *)path withArgs:(NSArray *)args andReturnStatus:(int *)status{
  NSTask *aTask = [[NSTask alloc] init];

  [aTask setLaunchPath:path];
  [aTask setArguments:args];

  [aTask setStandardInput:[NSPipe pipe]];
  [aTask setStandardOutput:[NSPipe pipe]];
  [aTask setStandardError: [aTask standardOutput]];

  [aTask launch];
  [aTask waitUntilExit];

  *status = [aTask terminationStatus];
  NSData *data = [[[aTask standardOutput] fileHandleForReading] readDataToEndOfFile];
  [aTask release];
  NSString *output = [CWTask stringWithCleanedUpUTF8String:(char *)[data bytes] length:[data length]];
  NSLog(@"%@",output);
  return output;
}

@end
