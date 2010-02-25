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
@synthesize devicePicker,convertButton,filename,dropBox,window;
@synthesize finishedConverting, showFile;      
@synthesize convertingView, convertingFilename, percentDone, progressIndicator;
@synthesize fFMPEGOutputWindow,fFMPEGOutputTextView;

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
    [self setDonePercentage:[NSNumber numberWithDouble:0]];
    [progressIndicator startAnimation:self];
    [NSThread detachNewThreadSelector:@selector(doFFMPEGConversion) toTarget:self withObject:nil];
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
-(IBAction) cancelButtonClick:(id)sender {
 int iResponse = 
        NSRunAlertPanel(@"Cancel Conversion",@"Are you sure you want cancel the conversion?",
                        @"No", @"Yes", /*third button*/nil/*,args for a printf-style msg go here*/);
  switch(iResponse) {
    case NSAlertDefaultReturn:
      break;
    case NSAlertAlternateReturn:
      [NSThread 
      [self setViewMode:ViewModeWithFile];
      break;
  }
}
-(void) convertingDone {
  [progressIndicator stopAnimation:self];
  [finishedConverting setStringValue:[NSString stringWithFormat:@"Finished converting %@", [filename stringValue]]];
  [self setViewMode:ViewModeFinished];
}
-(void) setDonePercentage:(NSNumber *)percent {
  [progressIndicator setDoubleValue:[percent doubleValue]];
  [percentDone setStringValue:[NSString stringWithFormat:@"%i%% done",[percent intValue]]];
}
-(char *) fFMPEGCommandLine {
  char *commandLine = malloc(1024);
  sprintf(commandLine,"tail -f ~/watchFile.txt");
  return commandLine;
}
-(FFMPEGStatus) parseFFMPEGOutput:(NSTextStorage *)storage fromPosition:(int)position {
  return FFMPEGStatusConverting;
}
-(void) doFFMPEGConversion {
  NSAutoreleasePool *pool =[[NSAutoreleasePool alloc] init];
  NSTextStorage *storage = [[[fFMPEGOutputTextView textContainer] textView] textStorage];
  char *commandLine = [self fFMPEGCommandLine];
  FILE *fp = popen(commandLine,"r");
  int bufsize = 1024; char *buf = malloc(bufsize);
  int fFMPEGStatus = FFMPEGStatusConverting, textPosition = 0;
  while(fFMPEGStatus == FFMPEGStatusConverting){
    if(fgets(buf,bufsize,fp)){
      [storage replaceCharactersInRange:NSMakeRange([storage length], 0)
	       withString:[NSString stringWithCString:buf]]; 
      fFMPEGStatus = [self parseFFMPEGOutput:storage fromPosition:textPosition];
      textPosition = [storage length];
    }
    usleep(100000);
  }
  fclose(fp); free(commandLine);
  [self performSelectorOnMainThread:@selector(convertingDone) withObject:nil waitUntilDone:NO];
  [pool release];
}
@end
