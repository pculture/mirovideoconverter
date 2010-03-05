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
#import "CWTaskWatcher.h"

@implementation RootViewController
@synthesize rootView,convertAVideo,dragAVideo,chooseAFile1,toSelectADifferent,chooseAFile2;
@synthesize filePath,devicePicker,convertButton,filename,dropBox,window;
@synthesize finishedConverting,showFile;      
@synthesize convertingView,convertingFilename,percentDone,progressIndicator,cancelButton,fFMPEGButton;
@synthesize fFMPEGOutputWindow,fFMPEGOutputTextView,conversionWatcher,speedFile;
@synthesize speedTestActive,fileSize,elapsedTime,percentPerOutputByte;

-(void) awakeFromNib {
  static BOOL firstTime = YES;
  if(firstTime){
    [devicePicker removeAllItems];
    [devicePicker addItemWithTitle:@"Pick a Device or Video Format"];
    [devicePicker addItemWithTitle:@"G1"];
    [devicePicker addItemWithTitle:@"PSP"];
    [devicePicker addItemWithTitle:@"Theora"];
    [dropBox registerForDraggedTypes: [NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
    firstTime = NO;
    [self setViewMode:ViewModeInitial];
  }
}
-(void) loadConvertingView {
  [NSBundle loadNibNamed:@"Converting" owner:self];
  [progressIndicator setMinValue:0];
  [progressIndicator setMaxValue:100];
  [NSBundle loadNibNamed:@"FFMPEGOutputWindow" owner:self];
}
-(void) setViewMode:(ViewMode)viewMode{
  switch(viewMode) {
  case ViewModeInitial:
    [self showView:ViewRoot];
    [self setAlphaValuesForViewMode:viewMode];
    [devicePicker selectItemAtIndex:0];
    //testing
    [devicePicker selectItemAtIndex:1];
    [self dropBoxView:nil fileDropped:@"/Users/cworth/Desktop/30Rock-part.avi"];
    //
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
    [convertingFilename setStringValue:[self fFMPEGOutputFile:[filename stringValue]]];
    [progressIndicator setDoubleValue:0];
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
  currentViewMode = viewMode;
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
      [conversionWatcher requestFinishWithStatus:EndStatusCancel];
      break;
    default:
      break;
    }
}

// Functions for ffmpeg conversion handling
-(void) doFFMPEGConversion {
  // testing
  [fFMPEGOutputWindow makeKeyAndOrderFront:self];  
  //
  if(![[devicePicker titleOfSelectedItem] compare:@"Theora"]){
    self.speedTestActive = YES;
    [self doSpeedTest];
  } else {
    self.speedTestActive = NO;
    [self doConversion];
  }
}
-(void) doConversion {
  [self startAConversion:filePath];
  [cancelButton setEnabled:YES];
  [fFMPEGButton setEnabled:YES];
}
-(void) convertingDone:(TaskEndStatus)status {
  [progressIndicator stopAnimation:self];
  switch(status) {
  case EndStatusOK:
    [finishedConverting setStringValue:[NSString stringWithFormat:@"Finished converting %@",
                                                 [convertingFilename stringValue]]];
    [self setViewMode:ViewModeFinished];
    break;
  case EndStatusError:  
    NSRunAlertPanel(@"Conversion Failed", @"Your file could not be converted.", @"OK", nil, nil);
  case EndStatusCancel:
    [self setViewMode:ViewModeWithFile];
    break;
  }
}
#define TEST_SIZE 1024*384
-(void) doSpeedTest {
  [cancelButton setEnabled:NO];
  [fFMPEGButton setEnabled:NO];
  [percentDone setStringValue:@"Initializing..."];
  // copy start of video to a smaller test file
  self.speedFile = [[[filePath stringByDeletingLastPathComponent]
                      stringByAppendingPathComponent:@"tmp"]
                     stringByAppendingPathExtension:[filePath pathExtension]];
  FILE *fpr = fopen([filePath UTF8String], "rb");
  FILE *fpw = fopen([speedFile UTF8String], "wb");
  char *buf = malloc(4096);
  int nwrote = 0;
  int nread;
  if(fpr && fpw && buf){
    while(feof(fpr)==0){
      nread = fread(buf, 1, 4096, fpr);
      if(nwrote+nread > TEST_SIZE){
        nwrote += fwrite(buf, 1, TEST_SIZE - nwrote, fpw);
        break;
      } else
        nwrote += fwrite(buf, 1, nread, fpw);
    }
    fclose(fpr); fclose(fpw);
    free(buf);

    if(nwrote){
      [self startAConversion:speedFile];
      return;
    }
  }
  [self convertingDone:EndStatusError];
}
-(void) finishUpSpeedTest {
  int inputFileSize=0, inputSpeedTestFileSize=0, outputSpeedTestFileSize=0;
  if ([[NSFileManager defaultManager] isReadableFileAtPath:filePath]){
    inputFileSize = [[[NSFileManager defaultManager]
                       attributesOfItemAtPath:filePath error:nil]
                      fileSize];
  }
  if([[NSFileManager defaultManager] isReadableFileAtPath:speedFile]){
    inputSpeedTestFileSize =
      [[[NSFileManager defaultManager]
         attributesOfItemAtPath:speedFile error:nil]
        fileSize];
  }
  outputSpeedTestFileSize = self.fileSize;
  if(inputFileSize && inputSpeedTestFileSize && outputSpeedTestFileSize)
    percentPerOutputByte = (float)100 /
      ((float)inputFileSize * outputSpeedTestFileSize/inputSpeedTestFileSize);
  else
    percentPerOutputByte = 0;
  // remove speedTest files
  if ( [[NSFileManager defaultManager] isReadableFileAtPath:speedFile] )
    [[NSFileManager defaultManager] removeItemAtPath:speedFile error:nil];
  NSString *outputFile = [self fFMPEGOutputFile:speedFile];
  if ( [[NSFileManager defaultManager] isReadableFileAtPath:outputFile] )
    [[NSFileManager defaultManager] removeItemAtPath:outputFile error:nil];
}
- (void)cwTaskWatcher:(CWTaskWatcher *)cwTaskWatcher ended:(TaskEndStatus)status {
  self.conversionWatcher = 0;
  if(status != EndStatusOK){
    if(self.speedTestActive)
      self.speedTestActive = NO;
    [self convertingDone:status];
  } else {
    if(self.speedTestActive){
      self.speedTestActive = NO;
      [self finishUpSpeedTest];
      [self doConversion];
    } else {
      [self convertingDone:status];
    }
  }
}
- (void)cwTaskWatcher:(CWTaskWatcher *)cwTaskWatcher updateString:(NSString *)output {

}
- (void)cwTaskWatcher:(CWTaskWatcher *)cwTaskWatcher updateFileInfo:(NSDictionary *)dict {
  self.fileSize = [[dict objectForKey:@"filesize"] intValue];;
  self.elapsedTime = [[dict objectForKey:@"elapsedTime"] floatValue];
  if(percentPerOutputByte) {
    double percent = self.percentPerOutputByte * self.fileSize * 0.9;
    percent = (percent > 99.1 ? 99 : percent);
    [progressIndicator setIndeterminate:NO];
    [progressIndicator setDoubleValue:percent];
    [percentDone setStringValue:[NSString stringWithFormat:@"%i%% done",(int)percent]];
  } else {
    [progressIndicator setIndeterminate:YES];
    [percentDone setStringValue:@"Converting..."];
  }
}
-(void) startAConversion:(NSString *)file {
  // initialize textbox for FFMPEG output window
  NSTextStorage *storage = [[[fFMPEGOutputTextView textContainer] textView] textStorage];
  NSAttributedString *string =
    [[NSAttributedString alloc]
      initWithString:[NSString stringWithFormat:@"%@ %@\n",[[self fFMPEGLaunchPath] lastPathComponent],
					  [[self fFMPEGArguments:file] componentsJoinedByString:@" "]]];
  [storage setAttributedString:string];
  [string release];
  CWTaskWatcher *aWatcher = [[CWTaskWatcher alloc] init];
  self.conversionWatcher = aWatcher;
  [aWatcher release];
  conversionWatcher.delegate = self;
  conversionWatcher.textStorage = storage;
  [conversionWatcher startTask:
                       [self fFMPEGLaunchPath]
                     withArgs:[self fFMPEGArguments:file]
                     andProgressFile:[self fFMPEGOutputFile:file]];
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
-(NSString *) fFMPEGOutputFile:(NSString *)inputFile {
  NSString *returnValue;
  if(![[devicePicker titleOfSelectedItem] compare:@"G1"])
    returnValue = [[inputFile stringByDeletingPathExtension] stringByAppendingPathExtension:@"g1.mp4"];
  else if(![[devicePicker titleOfSelectedItem] compare:@"PSP"])
    returnValue = [[inputFile stringByDeletingPathExtension] stringByAppendingPathExtension:@"psp.mp4"];
  else if(![[devicePicker titleOfSelectedItem] compare:@"Theora"])
    returnValue = [[inputFile stringByDeletingPathExtension] stringByAppendingPathExtension:@"theora.ogv"];
  return returnValue;
}
-(NSArray *) fFMPEGArguments:(NSString *)path {
  NSMutableArray *args = [NSMutableArray arrayWithCapacity:0];
  if(![[devicePicker titleOfSelectedItem] compare:@"G1"]){
    [args addObject:@"-i"];
    [args addObject:path];
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
    [args addObject:[self fFMPEGOutputFile:path]];
  } else if(![[devicePicker titleOfSelectedItem] compare:@"PSP"]){
    [args addObject:@"-i"];
    [args addObject:path];
    [args addObject:@"-b"];
    [args addObject:@"1200k"];
    [args addObject:@"-s"];
    [args addObject:@"320x240"];
    [args addObject:@"-vcodec"];
    [args addObject:@"mpeg4"];
    [args addObject:@"-ab"];
    [args addObject:@"128k"];
    [args addObject:@"-ar"];
    [args addObject:@"24000"];
    [args addObject:@"-acodec"];
    [args addObject:@"aac"];
    [args addObject:@"-mbd"];
    [args addObject:@"2"];
    [args addObject:@"-flags"];
    [args addObject:@"+4mv"];
    [args addObject:@"-trellis"];
    [args addObject:@"2"];
    [args addObject:@"-cmp"];
    [args addObject:@"2"];
    [args addObject:@"-subcmp"];
    [args addObject:@"2"];
    [args addObject:@"-r"];
    [args addObject:@"30000/1001"];
    [args addObject:[self fFMPEGOutputFile:path]];
  } else if(![[devicePicker titleOfSelectedItem] compare:@"Theora"]){
    [args addObject:path];
    [args addObject:@"-o"];
    [args addObject:[self fFMPEGOutputFile:path]];
    [args addObject:@"--videoquality"];
    [args addObject:@"8"];
    [args addObject:@"--audioquality"];
    [args addObject:@"6"];
    [args addObject:@"--frontend"];
  }
  return [NSArray arrayWithArray:args];
}
@end
