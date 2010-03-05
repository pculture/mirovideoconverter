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
#import "CWTaskWatcher.h"

@class ClickableText;

typedef enum { ViewRoot, ViewConverting } Views;
typedef enum { ViewModeInitial, ViewModeWithFile, ViewModeConverting, ViewModeFinished } ViewMode;
@interface RootViewController : NSObject <DropBoxViewDelegate,CWTaskWatcherDelegate>{
  NSView *rootView;
  ViewMode currentViewMode;
  NSTextField *convertAVideo;
  NSTextField *dragAVideo;
  ClickableText *chooseAFile1;
  NSTextField *toSelectADifferent;
  ClickableText *chooseAFile2;
  NSString *filePath;
  NSTextField *finishedConverting;
  NSTextField *showFile;      
  NSPopUpButton *devicePicker;
  NSButton *convertButton;
  NSTextField *filename;
  DropBoxView *dropBox;
  NSWindow *window;
  NSView *convertingView;
  NSTextField *convertingFilename;	 
  NSTextField *percentDone;
  NSProgressIndicator *progressIndicator;
  NSButton *cancelButton;
  NSButton *fFMPEGButton;
  NSWindow *fFMPEGOutputWindow;
  NSTextView *fFMPEGOutputTextView;
  CWTaskWatcher *conversionWatcher;
  NSString *speedFile;
  float elapsedTime;
  int fileSize;
  float percentPerOutputByte;
  BOOL speedTestActive;
}
@property(nonatomic,retain) IBOutlet NSView *rootView;
@property(nonatomic,retain) IBOutlet NSTextField *convertAVideo;
@property(nonatomic,retain) IBOutlet NSTextField *dragAVideo;
@property(nonatomic,retain) IBOutlet NSTextField *chooseAFile1;
@property(nonatomic,retain) IBOutlet NSTextField *toSelectADifferent;
@property(nonatomic,retain) IBOutlet NSTextField *chooseAFile2;
@property(nonatomic,retain) NSString *filePath;
@property(nonatomic,retain) IBOutlet NSTextField *finishedConverting;
@property(nonatomic,retain) IBOutlet NSTextField *showFile;      
@property(nonatomic,retain) IBOutlet NSPopUpButton *devicePicker;
@property(nonatomic,retain) IBOutlet NSButton *convertButton;
@property(nonatomic,retain) IBOutlet NSTextField *filename;
@property(nonatomic,retain) IBOutlet DropBoxView *dropBox;
@property(nonatomic,retain) IBOutlet NSWindow *window;
@property(nonatomic,retain) IBOutlet NSView *convertingView;
@property(nonatomic,retain) IBOutlet NSTextField *convertingFilename;	    
@property(nonatomic,retain) IBOutlet NSTextField *percentDone;		    
@property(nonatomic,retain) IBOutlet NSProgressIndicator *progressIndicator;
@property(nonatomic,retain) IBOutlet NSButton *cancelButton;
@property(nonatomic,retain) IBOutlet NSButton *fFMPEGButton;
@property(nonatomic,retain) IBOutlet NSWindow *fFMPEGOutputWindow;
@property(nonatomic,retain) IBOutlet NSTextView *fFMPEGOutputTextView;
@property(nonatomic,retain) CWTaskWatcher *conversionWatcher;
@property(nonatomic,retain) NSString *speedFile;
@property(nonatomic,assign) BOOL speedTestActive;
@property(nonatomic,assign) int fileSize;
@property(nonatomic,assign) float elapsedTime;
@property(nonatomic,assign) float percentPerOutputByte;

-(void) loadConvertingView;
-(void) setViewMode:(ViewMode)viewMode;
-(void) setAlphaValuesForViewMode:(ViewMode)viewMode;
-(NSString*) formatFilename:(NSString *)inFile;
-(IBAction) chooseAFile:(id)sender;
-(IBAction) selectADevice:(id)sender;
-(IBAction) convertButtonClick:(id)sender;
-(IBAction) showFileClick:(id)sender;
-(void) maybeEnableConvertButton;
-(void) showView:(int)whichView;
-(IBAction) cancelButtonClick:(id)sender;
-(IBAction) fFMPEGButtonClick:(id)sender;
-(void) doFFMPEGConversion;
-(void) doConversion;
-(void) convertingDone:(TaskEndStatus)status;
-(void) doSpeedTest;
-(void) finishUpSpeedTest;
-(void) startAConversion:(NSString *)file;
-(NSString *) fFMPEGLaunchPath;
-(NSString *) fFMPEGOutputFile:(NSString *)inputFile;
-(NSArray *) fFMPEGArguments:(NSString *)path;
@end
