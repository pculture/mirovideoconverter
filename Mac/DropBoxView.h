/* -*- mode: objc -*- */
//
//  RootViewController.h
//  Miro Video Converter
//
//  Created by C Worth on 2/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DropBoxView : NSView {
  id delegate;
}
@property(nonatomic,retain) id delegate;
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender;
- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender;
@end

@protocol DropBoxViewDelegate
- (void)dropBoxView:(DropBoxView *)dropBoxView fileDropped:(NSString *)aFilename;
@end

