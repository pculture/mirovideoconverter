/* -*- mode: objc -*- */
//
//  RootViewController.m
//  Miro Video Converter
//
//  Created by C Worth on 2/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DropBoxView.h"
#import <Cocoa/Cocoa.h>

@implementation DropBoxView
@synthesize delegate;

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {

  NSPasteboard *pboard;
  NSDragOperation sourceDragMask;

  sourceDragMask = [sender draggingSourceOperationMask];
  pboard = [sender draggingPasteboard];
 
  if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
    if (sourceDragMask & NSDragOperationLink) {
      return NSDragOperationLink;
    } else if (sourceDragMask & NSDragOperationCopy) {
      return NSDragOperationCopy;
    }
  }
  return NSDragOperationNone;
}
- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {

  NSPasteboard *pboard;
  NSDragOperation sourceDragMask;
 
  sourceDragMask = [sender draggingSourceOperationMask];
  pboard = [sender draggingPasteboard];
 
  if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
    NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
    if([files count] == 1){
      [delegate dropBoxView:self fileDropped:[files objectAtIndex:0]];
      return YES;
    }
  }
  return NO;
}
@end
