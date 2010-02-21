/* -*- mode: objc -*- */
//
//  RootViewController.h
//  Miro Video Converter
//
//  Created by C Worth on 2/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class ClickableText;

typedef enum { initialView, withFileView, convertingView, finishedView } ViewMode;

@interface RootViewController : NSObject {

	IBOutlet NSTextField *dragAVideoLabel;
	IBOutlet ClickableText *chooseAFile1;
	IBOutlet NSTextField *toSelectADifferent;
	IBOutlet ClickableText *chooseAFile2;
	IBOutlet NSPopUpButton *devicePicker;
	IBOutlet NSButton *convertButton;
	IBOutlet NSTextField *filename;
}
@property(nonatomic,retain) IBOutlet NSTextField *dragAVideoLabel;
@property(nonatomic,retain) IBOutlet NSTextField *chooseAFile1;
@property(nonatomic,retain) IBOutlet NSTextField *toSelectADifferent;
@property(nonatomic,retain) IBOutlet NSTextField *chooseAFile2;
@property(nonatomic,retain) IBOutlet NSPopUpButton *devicePicker;
@property(nonatomic,retain) IBOutlet NSButton *convertButton;
@property(nonatomic,retain) IBOutlet NSTextField *filename;

-(IBAction) convertButtonClick:(id)sender;
-(IBAction) chooseAFile:(id)sender;
-(IBAction) fileDrugToBox:(id)sender;
-(void) setViewMode:(ViewMode)viewMode;

@end
