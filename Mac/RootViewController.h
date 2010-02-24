/* -*- mode: objc -*- */
//
//  RootViewController.h
//  Miro Video Converter
//
//  Created by C Worth on 2/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DropBoxView.h"

@class ClickableText;

typedef enum { initialView, withFileView, convertingView, finishedView } ViewMode;

@interface RootViewController : NSObject <DropBoxViewDelegate>{
  NSTextField *dragAVideo;
  ClickableText *chooseAFile1;
  NSTextField *toSelectADifferent;
  ClickableText *chooseAFile2;
  NSPopUpButton *devicePicker;
  NSButton *convertButton;
  NSTextField *filename;
  DropBoxView *dropBox;
  NSWindow *window;
}
@property(nonatomic,retain) IBOutlet NSTextField *dragAVideo;
@property(nonatomic,retain) IBOutlet NSTextField *chooseAFile1;
@property(nonatomic,retain) IBOutlet NSTextField *toSelectADifferent;
@property(nonatomic,retain) IBOutlet NSTextField *chooseAFile2;
@property(nonatomic,retain) IBOutlet NSPopUpButton *devicePicker;
@property(nonatomic,retain) IBOutlet NSButton *convertButton;
@property(nonatomic,retain) IBOutlet NSTextField *filename;
@property(nonatomic,retain) IBOutlet DropBoxView *dropBox;
@property(nonatomic,retain) IBOutlet NSWindow *window;

-(void) setViewMode:(ViewMode)viewMode;
-(NSString*) formatFilename:(NSString *)inFile;
-(IBAction) chooseAFile:(id)sender;
-(IBAction) selectADevice:(id)sender;
-(IBAction) convertButtonClick:(id)sender;
-(void) maybeEnableConvertButton;
@end
