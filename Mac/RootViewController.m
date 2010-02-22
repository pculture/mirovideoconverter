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

@synthesize dragAVideo,chooseAFile1,toSelectADifferent,chooseAFile2,devicePicker,convertButton,filename,dropBox,window;

-(IBAction) convertButtonClick:(id)sender {
}
-(void) setViewMode:(ViewMode)viewMode{

  switch(viewMode) {
  case initialView:
    dragAVideo.alphaValue =         1;
    chooseAFile1.alphaValue =       1;
    toSelectADifferent.alphaValue = 0;
    chooseAFile2.alphaValue =       0;
    devicePicker.alphaValue =       1;
    convertButton.alphaValue =      1;
    filename.alphaValue =           0;
    [convertButton setTitle:@"Convert"];
    [dropBox registerForDraggedTypes: [NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
    break;
  case withFileView:
    dragAVideo.alphaValue =         0;
    chooseAFile1.alphaValue =       0;
    toSelectADifferent.alphaValue = 1;
    chooseAFile2.alphaValue =       1;
    devicePicker.alphaValue =       1;
    convertButton.alphaValue =      1;
    filename.alphaValue =           1;
    [convertButton setTitle:@"Convert"];
    [dropBox registerForDraggedTypes: [NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
    break;
  case convertingView:
    dragAVideo.alphaValue =         0;
    chooseAFile1.alphaValue =       0;
    toSelectADifferent.alphaValue = 0;
    chooseAFile2.alphaValue =       0;
    devicePicker.alphaValue =       1;
    convertButton.alphaValue =      1;
    filename.alphaValue =           0;
    [convertButton setTitle:@"Convert"];
    [dropBox registerForDraggedTypes: [NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
    break;
  case finishedView:
    dragAVideo.alphaValue =         1;
    chooseAFile1.alphaValue =       1;
    toSelectADifferent.alphaValue = 1;
    chooseAFile2.alphaValue =       0;
    devicePicker.alphaValue =       1;
    convertButton.alphaValue =      1;
    filename.alphaValue =           0;
    [convertButton setTitle:@"Convert"];
    [dropBox registerForDraggedTypes: [NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
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
  [self setViewMode:withFileView];
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
    [self setViewMode:withFileView];
  }
}
@end
