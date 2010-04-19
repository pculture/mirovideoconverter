/* -*- mode: objc -*- */
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
//  RootViewController.h
//  Miro Video Converter
//
//  Created by C Worth on 2/18/10.
//

#import <Cocoa/Cocoa.h>
#import "DropBoxView.h"
#import "CWTaskWatcher.h"

@class ClickableText;
@class VideoConversionCommands;

extern char *deviceNames[];

typedef enum { ViewRoot, ViewConverting } Views;
typedef enum { ViewModeInitial, ViewModeWithFile, ViewModeConverting, ViewModeFinished } ViewMode;
@interface RootViewController : NSObject <DropBoxViewDelegate,CWTaskWatcherDelegate>{
  NSMenuItem *checkForUpdates;
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
  NSButton *sendToITunes;
  NSButton *convertButton;
  NSTextField *filename;
  DropBoxView *dropBox;
  NSWindow *window;
  NSView *convertingView;
  NSTextField *convertingFilename;	 
  NSTextField *percentDone;
  NSProgressIndicator *progressIndicator;
  NSButton *cancelButton;
  NSWindow *fFMPEGOutputWindow;
  NSTextView *fFMPEGOutputTextView;
  CWTaskWatcher *conversionWatcher;
  NSString *speedFile;
  VideoConversionCommands *video;
  BOOL ffmpegFinishedOkayBeforeError;
  float elapsedTime;
  int fileSize;
  float percentPerOutputByte;
  BOOL formatQueryActive;
  float videoLength;
  float previousPercentDone;
}
@property(nonatomic,retain) IBOutlet NSMenuItem *checkForUpdates;
@property(nonatomic,retain) IBOutlet NSView *rootView;
@property(nonatomic,retain) IBOutlet NSTextField *convertAVideo;
@property(nonatomic,retain) IBOutlet NSTextField *dragAVideo;
@property(nonatomic,retain) IBOutlet ClickableText *chooseAFile1;
@property(nonatomic,retain) IBOutlet NSTextField *toSelectADifferent;
@property(nonatomic,retain) IBOutlet ClickableText *chooseAFile2;
@property(nonatomic,retain) NSString *filePath;
@property(nonatomic,retain) IBOutlet NSTextField *finishedConverting;
@property(nonatomic,retain) IBOutlet NSTextField *showFile;      
@property(nonatomic,retain) IBOutlet NSPopUpButton *devicePicker;
@property(nonatomic,retain) IBOutlet NSButton *sendToITunes;
@property(nonatomic,retain) IBOutlet NSButton *convertButton;
@property(nonatomic,retain) IBOutlet NSTextField *filename;
@property(nonatomic,retain) IBOutlet DropBoxView *dropBox;
@property(nonatomic,retain) IBOutlet NSWindow *window;
@property(nonatomic,retain) IBOutlet NSView *convertingView;
@property(nonatomic,retain) IBOutlet NSTextField *convertingFilename;	    
@property(nonatomic,retain) IBOutlet NSTextField *percentDone;		    
@property(nonatomic,retain) IBOutlet NSProgressIndicator *progressIndicator;
@property(nonatomic,retain) IBOutlet NSButton *cancelButton;
@property(nonatomic,retain) IBOutlet NSWindow *fFMPEGOutputWindow;
@property(nonatomic,retain) IBOutlet NSTextView *fFMPEGOutputTextView;
@property(nonatomic,retain) CWTaskWatcher *conversionWatcher;
@property(nonatomic,retain) NSString *speedFile;
@property(nonatomic,retain) VideoConversionCommands *video;
@property(nonatomic,assign) BOOL formatQueryActive;
@property(nonatomic,assign) int fileSize;
@property(nonatomic,assign) float elapsedTime;
@property(nonatomic,assign) float percentPerOutputByte;
@property(nonatomic,assign) float videoLength;
@property(nonatomic,assign) float previousPercentDone;
@property(nonatomic,assign) BOOL ffmpegFinishedOkayBeforeError;

-(void) loadConvertingView;
-(void) setViewMode:(ViewMode)viewMode;
-(void) revealViewControls:(ViewMode)viewMode;
-(void) revealSubview:(NSView *)subview show:(BOOL)show;
-(NSString *)formatFilename:(NSString *)inFile maxLength:(int)maxLength;
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
-(void) doFormatQuery;
-(void) finishUpFormatQuery;
-(void) startAConversion:(NSString *)file forDevice:(NSString *)device synchronous:(BOOL)sync;
-(void)sendFileToITunes;

@end
