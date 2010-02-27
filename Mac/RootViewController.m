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

@implementation RootViewController
@synthesize rootView,convertAVideo,dragAVideo,chooseAFile1,toSelectADifferent,chooseAFile2;
@synthesize filePath,devicePicker,convertButton,filename,dropBox,window;
@synthesize finishedConverting,showFile;      
@synthesize convertingView,convertingFilename,percentDone,progressIndicator;
@synthesize fFMPEGOutputWindow,fFMPEGOutputTextView,conversionTask;
@synthesize outputPipe,conversionCancelled;

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
    [devicePicker selectItemAtIndex:0];
    [self maybeEnableConvertButton];
    break;
  case ViewModeWithFile:
    [self showView:ViewRoot];
    [self maybeEnableConvertButton];
    break;
  case ViewModeConverting:
    [self showView:ViewConverting];
    [convertingFilename setStringValue:[filename stringValue]];
    [self setDonePercentage:0];
    [progressIndicator startAnimation:self];
    [self doFFMPEGConversion];
    break;
  case ViewModeFinished:
    [self showView:ViewRoot];
    [devicePicker selectItemAtIndex:0];
    [self maybeEnableConvertButton];
    break;
  default:
    break;
  }
  [self setAlphaValuesForViewMode:viewMode];
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
  [self maybeEnableConvertButton];
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
    [filename setStringValue:[self formatFilename:[[sheet filenames] objectAtIndex:0]]];
    [sheet close];
    [self setViewMode:ViewModeWithFile];
  }
  [self maybeEnableConvertButton];
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
-(IBAction) convertButtonClick:(id)sender {
  [self setViewMode:ViewModeConverting];
}
-(IBAction) showFileClick:(id)sender {
  [[NSWorkspace sharedWorkspace] openFile:[filePath stringByDeletingLastPathComponent] withApplication:@"Finder"];
}
-(IBAction) cancelButtonClick:(id)sender {
 int iResponse = 
        NSRunAlertPanel(@"Cancel Conversion",@"Are you sure you want cancel the conversion?",
                        @"No", @"Yes", /*third button*/nil/*,args for a printf-style msg go here*/);
  switch(iResponse) {
    case NSAlertDefaultReturn:
      break;
    case NSAlertAlternateReturn:
      self.conversionCancelled = YES;
      if([conversionTask isRunning])
	[conversionTask terminate];
      break;
  }
}
-(IBAction) fFMPEGButtonClick:(id)sender {
  [fFMPEGOutputWindow makeKeyAndOrderFront:self];
}
-(void) setDonePercentage:(int)percent {
  [progressIndicator setDoubleValue:percent];
  [percentDone setStringValue:[NSString stringWithFormat:@"%i%% done",percent]];
}
-(void) convertingDoneWithStatus:(FFMPEGStatus)status {
  [progressIndicator stopAnimation:self];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:NSTaskDidTerminateNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleReadCompletionNotification object:nil];
  self.outputPipe = 0;
  self.conversionTask = 0;
  switch(status) {
  case FFMPEGStatusDone:
    [finishedConverting setStringValue:[NSString stringWithFormat:@"Finished converting %@", [filename stringValue]]];
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
#define FFMPEG_EXEC_NSSTRING @"ffmpeg.sh"
/**
  setup FFMPEG task with an output pipe
  request background read and notification
*/
-(void) doFFMPEGConversion {
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
  self.conversionCancelled = NO;
  [aTask setLaunchPath:[[NSBundle mainBundle] pathForResource:@"ffmpeg" ofType:@""]];
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
  [aTask launch];
  [[outputPipe fileHandleForReading] readInBackgroundAndNotify];
}
-(FFMPEGStatus) parseFFMPEGOutput:(NSTextStorage *)storage fromPosition:(int)position {
  return FFMPEGStatusConverting;
}
-(void) conversionTaskDataAvailable:(NSNotification *)note {
  static int textPosition = 0;
  NSTextStorage *storage = [[[fFMPEGOutputTextView textContainer] textView] textStorage];
  NSData *data = [[note userInfo] objectForKey:NSFileHandleNotificationDataItem];
  if(data && [data length])
    [storage replaceCharactersInRange:NSMakeRange([storage length], 0)
	     withString:[NSString stringWithUTF8String:[data bytes]]];
  FFMPEGStatus fFMPEGStatus = [self parseFFMPEGOutput:storage fromPosition:textPosition];
  textPosition = [storage length];
  [self setDonePercentage:(float)rand()/RAND_MAX*100];
  [(NSFileHandle *)[note object] readInBackgroundAndNotify];
  fFMPEGStatus;
}
-(void) conversionTaskCompleted:(NSNotification *)note {
  FFMPEGStatus fFMPEGStatus = FFMPEGStatusDone;
  if(conversionCancelled)
    fFMPEGStatus = FFMPEGStatusCancelled;
  else
    if([[note object] terminationStatus])
      fFMPEGStatus = FFMPEGStatusError;
  [self convertingDoneWithStatus:fFMPEGStatus];
}
-(NSArray *) fFMPEGArguments {
  NSMutableArray *args = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
  [args addObject:filePath];
  return args;
}
@end
