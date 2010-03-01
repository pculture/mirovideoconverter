/* -*- mode: objc -*- */
//
//  RootViewController.m
//  Miro Video Converter
//
//  Created by C Worth on 2/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import <Cocoa/Cocoa.h>
#import "ClickableText.h"
#import "DropBoxView.h"

#define FFMPEG_EXEC_NSSTRING @"ffmpeg.sh"

@implementation RootViewController
@synthesize rootView,convertAVideo,dragAVideo,chooseAFile1,toSelectADifferent,chooseAFile2;
@synthesize filePath,devicePicker,convertButton,filename,dropBox,window;
@synthesize finishedConverting,showFile;      
@synthesize convertingView,convertingFilename,percentDone,progressIndicator;
@synthesize fFMPEGOutputWindow,fFMPEGOutputTextView,conversionTask;
@synthesize outputPipe;
@synthesize timer;

-(void) awakeFromNib {
  static BOOL firstTime = YES;
  if(firstTime){
    [self setViewMode:ViewModeInitial];
    [devicePicker removeAllItems];
    [devicePicker addItemWithTitle:@"Pick a Device or Video Format"];
    [devicePicker addItemWithTitle:@"G1"];
    [devicePicker addItemWithTitle:@"PSP"];
    [devicePicker addItemWithTitle:@"Theora"];
    [convertButton setEnabled:NO];
    [dropBox registerForDraggedTypes: [NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
    firstTime = NO;
  }
}
-(void) loadConvertingView {
  [NSBundle loadNibNamed:@"Converting" owner:self];
  [progressIndicator setMinValue:0];
  [progressIndicator setMaxValue:100];
  [progressIndicator setIndeterminate:NO];
  [NSBundle loadNibNamed:@"FFMPEGOutputWindow" owner:self];
}
-(void) setViewMode:(ViewMode)viewMode{
  switch(viewMode) {
  case ViewModeInitial:
    [self showView:ViewRoot];
    [self setAlphaValuesForViewMode:viewMode];
    [devicePicker selectItemAtIndex:0];
    [self maybeEnableConvertButton];
    break;
  case ViewModeWithFile:
    [self showView:ViewRoot];
    [self setAlphaValuesForViewMode:viewMode];
    [self maybeEnableConvertButton];
    break;
  case ViewModeConverting:
    [self showView:ViewConverting];
    [self setAlphaValuesForViewMode:viewMode];
    [convertingFilename setStringValue:[filename stringValue]];
    [self setDonePercentage:0];
    [progressIndicator startAnimation:self];
    [self doFFMPEGConversion];
    break;
  case ViewModeFinished:
    [self showView:ViewRoot];
    [self setAlphaValuesForViewMode:viewMode];
    [devicePicker selectItemAtIndex:0];
    [self maybeEnableConvertButton];
    break;
  default:
    break;
  }
}
-(void) showView:(int)whichView {
  NSView *theView;
  switch(whichView) {
  case ViewRoot:
    theView = rootView;
    break;
  case ViewConverting:
    if(!convertingView)
      [self loadConvertingView];
    theView = convertingView;
    break;
  default:
    break;
  }
  if([window contentView] != theView){
    [[window contentView] removeFromSuperview];
    [window setContentView:theView];
  }
}
-(void) setAlphaValuesForViewMode:(ViewMode)viewMode{
  switch(viewMode) {
  case ViewModeInitial:
    convertAVideo.alphaValue =      1;
    dragAVideo.alphaValue =         1;
    chooseAFile1.alphaValue =       1;
    toSelectADifferent.alphaValue = 0;
    chooseAFile2.alphaValue =       0;
    devicePicker.alphaValue =       1;
    convertButton.alphaValue =      1;
    filename.alphaValue =           0;
    finishedConverting.alphaValue = 0;
    showFile.alphaValue =           0;
    break;
  case ViewModeWithFile:
    convertAVideo.alphaValue =      1;
    dragAVideo.alphaValue =         0;
    chooseAFile1.alphaValue =       0;
    toSelectADifferent.alphaValue = 1;
    chooseAFile2.alphaValue =       1;
    devicePicker.alphaValue =       1;
    convertButton.alphaValue =      1;
    filename.alphaValue =           1;
    finishedConverting.alphaValue = 0;
    showFile.alphaValue =           0;
    break;
  case ViewModeConverting:
    break;
  case ViewModeFinished:
    convertAVideo.alphaValue =      0;
    dragAVideo.alphaValue =         1;
    chooseAFile1.alphaValue =       1;
    toSelectADifferent.alphaValue = 0;
    chooseAFile2.alphaValue =       0;
    devicePicker.alphaValue =       1;
    convertButton.alphaValue =      1;
    filename.alphaValue =           0;
    finishedConverting.alphaValue = 1;
    showFile.alphaValue =           1;
    break;
  default:
    break;
  }
}

// Functions for root view
- (NSString *)formatFilename:(NSString *)inFile {
  int maxLength = 37;
  NSString *outFile = [inFile stringByAbbreviatingWithTildeInPath];
  if([outFile length] > maxLength)
    outFile = [outFile lastPathComponent];
  if([outFile length] > maxLength){
    NSRange range = { 0, (maxLength-3)/2 - 1 };
    outFile = [NSString stringWithFormat:@"%@...%@",
			[outFile substringWithRange:range],
			[outFile substringFromIndex:[outFile length] - (maxLength-3)/2]];
  }
  return outFile;
}
- (void)dropBoxView:(DropBoxView *)dropBoxView fileDropped:(NSString *)aFilename {
  self.filePath = aFilename;
  [filename setStringValue:[self formatFilename:aFilename]];
  [self setViewMode:ViewModeWithFile];
}
-(IBAction) chooseAFile:(id)sender {
  [[NSOpenPanel openPanel] beginSheetForDirectory:nil
			   file:nil
			   types:nil
			   modalForWindow:[self window]
			   modalDelegate:self
			   didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:)
			   contextInfo:nil];
}
- (void)openPanelDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode
	    contextInfo:(void *)contextInfo {
  if(returnCode == NSOKButton) {
    self.filePath = [[sheet filenames] objectAtIndex:0];
    [sheet close];
    [filename setStringValue:[self formatFilename:filePath]];
    [self setViewMode:ViewModeWithFile];
  }
}
-(IBAction) selectADevice:(id)sender {
  [self maybeEnableConvertButton];
}
-(void) maybeEnableConvertButton {
  if([devicePicker indexOfSelectedItem] != 0 && filename.alphaValue > 0)
    [convertButton setEnabled:YES];
  else
    [convertButton setEnabled:NO];
}
-(IBAction) convertButtonClick:(id)sender {
  [self setViewMode:ViewModeConverting];
}
-(IBAction) showFileClick:(id)sender {
  [[NSWorkspace sharedWorkspace] openFile:[filePath stringByDeletingLastPathComponent] withApplication:@"Finder"];
}

// Functions for converting view
/**
  setup FFMPEG task with an output pipe
  request background read and notify
*/
-(void) doFFMPEGConversion {
  // initialize textbox for FFMPEG output window
  NSTextStorage *storage = [[[fFMPEGOutputTextView textContainer] textView] textStorage];
  NSAttributedString *string = [[NSAttributedString alloc] initWithString:@""];
  [storage setAttributedString:string];
  [string release];
  
  self.outputPipe = [NSPipe pipe];
  NSFileHandle *output = [outputPipe fileHandleForReading];
  [[NSNotificationCenter defaultCenter]
    addObserver:self selector:@selector(conversionTaskDataAvailable:)
    name:NSFileHandleReadCompletionNotification object:output];
  
  NSTask *aTask = [[NSTask alloc] init];
  self.conversionTask = aTask;
  [aTask release];
  
  [aTask setLaunchPath:[self fFMPEGLaunchPath]];
  [aTask setArguments:[self fFMPEGArguments]];

  NSMutableDictionary *environment =
    [[NSMutableDictionary alloc]
      initWithDictionary:[[NSProcessInfo processInfo] environment]];
  [environment setObject:@"YES" forKey:@"NSUnbufferedIO"];
  [aTask setEnvironment:environment];
  [environment release];

  [aTask setStandardOutput:outputPipe];
  [aTask setStandardError:outputPipe];

  [[NSNotificationCenter defaultCenter]
    addObserver:self selector:@selector(conversionTaskCompleted:)
    name:NSTaskDidTerminateNotification object:aTask];

  [self fFMPEGButtonClick:self];

  fFMPEGStatus = FFMPEGStatusConverting;
  [aTask launch];

  [[outputPipe fileHandleForReading] readInBackgroundAndNotify];
}
-(NSString *) fFMPEGLaunchPath {
  if(![[devicePicker titleOfSelectedItem] compare:@"G1"])
    return [[NSBundle mainBundle] pathForResource:@"ffmpeg" ofType:@""];
  else if(![[devicePicker titleOfSelectedItem] compare:@"PSP"])
    return [[NSBundle mainBundle] pathForResource:@"ffmpeg" ofType:@""];
  else if(![[devicePicker titleOfSelectedItem] compare:@"Theora"])
    return [[NSBundle mainBundle] pathForResource:@"ffmpeg2theora" ofType:@""];
  return nil;
}
-(NSArray *) fFMPEGArguments {
  NSMutableArray *args = [NSMutableArray arrayWithCapacity:0];
  if(![[devicePicker titleOfSelectedItem] compare:@"G1"]){
    [args addObject:@"-i"];
    [args addObject:filePath];
    [args addObject:@"-y"];
    [args addObject:@"-fpre"];
    [args addObject:[[NSBundle mainBundle] pathForResource:@"libx264hq" ofType:@"ffpreset"]];
    [args addObject:@"-aspect"];
    [args addObject:@"3:2"];
    [args addObject:@"-s"];
    [args addObject:@"400x300"];
    [args addObject:@"-r"];
    [args addObject:@"23.976"];
    [args addObject:@"-vcodec"];
    [args addObject:@"libx264"];
    [args addObject:@"-b"];
    [args addObject:@"480k"];
    [args addObject:@"-acodec"];
    [args addObject:@"aac"];
    [args addObject:@"-ab"];
    [args addObject:@"96k"];
    [args addObject:@"-threads"];
    [args addObject:@"0"];
    [args addObject:[[filePath stringByDeletingPathExtension]
		      stringByAppendingPathExtension:@"g1.mp4"]];
  } else if(![[devicePicker titleOfSelectedItem] compare:@"PSP"]){
    [args addObject:@"-i"];
    [args addObject:filePath];
    [args addObject:@"-y"];
    [args addObject:@"-b"];
    [args addObject:@"300k"];
    [args addObject:@"-s"];
    [args addObject:@"320x240"];
    [args addObject:@"-vcodec"];
    [args addObject:@"libxvid"];
    [args addObject:@"-ab"];
    [args addObject:@"32k"];
    [args addObject:@"-ar"];
    [args addObject:@"24000"];
    [args addObject:@"-acodec"];
    [args addObject:@"aac"];
    [args addObject:[[filePath stringByDeletingPathExtension]
		      stringByAppendingPathExtension:@"psp.mp4"]];
  } else if(![[devicePicker titleOfSelectedItem] compare:@"Theora"]){
    [args addObject:filePath];
    [args addObject:@"-o"];
    [args addObject:[[filePath stringByDeletingPathExtension]
		      stringByAppendingPathExtension:@"theora.ogv"]];
    [args addObject:@"--videoquality"];
    [args addObject:@"8"];
    [args addObject:@"--audioquality"];
    [args addObject:@"6"];
    [args addObject:@"--frontend"];
  }
  return [NSArray arrayWithArray:args];
}
-(void) conversionTaskDataAvailable:(NSNotification *)note {
  static int textPosition = 0;
  NSTextStorage *storage = [[[fFMPEGOutputTextView textContainer] textView] textStorage];
  NSData *data = [[note userInfo] objectForKey:NSFileHandleNotificationDataItem];
  if(data && [data length])
    [storage replaceCharactersInRange:NSMakeRange([storage length], 0)
	     withString:[NSString stringWithUTF8String:[data bytes]]];
  [self parseFFMPEGOutput:storage fromPosition:textPosition];
  textPosition = [storage length];
  [self setDonePercentage:(float)rand()/RAND_MAX*100];
  [(NSFileHandle *)[note object] readInBackgroundAndNotify];
}
-(void) parseFFMPEGOutput:(NSTextStorage *)storage fromPosition:(int)position {
  if(fFMPEGStatus == FFMPEGStatusConverting) {


  }// don't change a cancel, done or error
}
-(void) conversionTaskCompleted:(NSNotification *)note {
  // never change a cancel
  if(fFMPEGStatus != FFMPEGStatusCancelled){
    if([[note object] terminationStatus])
      fFMPEGStatus = FFMPEGStatusError;
    else
      fFMPEGStatus = FFMPEGStatusDone;
  }
  // Reschedule to allow final output to pipe to window
  self.timer = 
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self
	     selector:@selector(convertingDone:)
	     userInfo:nil
	     repeats:NO];
}
-(void) convertingDone:(NSTimer *)timer {
  [progressIndicator stopAnimation:self];
  [[NSNotificationCenter defaultCenter] removeObserver:self
					name:NSTaskDidTerminateNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self
					name:NSFileHandleReadCompletionNotification object:nil];
  self.outputPipe = 0;
  self.conversionTask = 0;
  switch(fFMPEGStatus) {
  case FFMPEGStatusDone:
    [finishedConverting setStringValue:[NSString stringWithFormat:@"Finished converting %@",
						 [convertingFilename stringValue]]];
    [self setViewMode:ViewModeFinished];
    break;
  case FFMPEGStatusCancelled:
    [self setViewMode:ViewModeWithFile];
    break;
  case FFMPEGStatusError:  
    NSRunAlertPanel(@"Conversion Failed", @"Your file could not be converted.", @"OK", nil, nil);
    [self setViewMode:ViewModeWithFile];
    break;
  default:
    break;
  }
}
-(IBAction) fFMPEGButtonClick:(id)sender {
  [fFMPEGOutputWindow makeKeyAndOrderFront:self];
}
-(IBAction) cancelButtonClick:(id)sender {
  int iResponse = 
    NSRunAlertPanel(@"Cancel Conversion",@"Are you sure you want cancel the conversion?",
		    @"No", @"Yes", /*third button*/nil/*,args for a printf-style msg go here*/);
  switch(iResponse) {
  case NSAlertDefaultReturn:
    break;
  case NSAlertAlternateReturn:
    fFMPEGStatus = FFMPEGStatusCancelled;
    if([conversionTask isRunning])
      [conversionTask terminate];
    break;
  default:
    break;
  }
}
-(void) setDonePercentage:(int)percent {
  [progressIndicator setDoubleValue:percent];
  [percentDone setStringValue:[NSString stringWithFormat:@"%i%% done",percent]];
}
@end
