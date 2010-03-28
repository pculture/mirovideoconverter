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
- (void) endTask;
+ (NSString *) performSynchronousTask:(NSString *)path withArgs:(NSArray *)args andReturnStatus:(int *)status;
@end

@protocol CWTaskDelegate
- (void) cwTask:(CWTask *)cwtask update:(NSDictionary *)info;
- (void) cwTask:(CWTask *)cwtask ended:(int)returnValue;
@end
