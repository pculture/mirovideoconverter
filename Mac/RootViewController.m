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

#define DROPBOX_MAX_FILE_LENGTH 32
#define CONVERTING_MAX_FILE_LENGTH 45
#define CONVERTING_DONE_MAX_FILE_LENGTH 27

@implementation RootViewController
@synthesize rootView,convertAVideo,dragAVideo,chooseAFile1,toSelectADifferent,chooseAFile2;
@synthesize filePath,devicePicker,convertButton,filename,dropBox,window;
@synthesize finishedConverting,showFile;      
@synthesize convertingView,convertingFilename,percentDone,progressIndicator,cancelButton;
@synthesize fFMPEGOutputWindow,fFMPEGOutputTextView,conversionWatcher,speedFile;
@synthesize speedTestActive,fileSize,elapsedTime,percentPerOutputByte,videoLength, previousPercentDone;

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
    [convertAVideo setStringValue:@"Convert a Video"];
    [self revealViewControls:viewMode];
    [devicePicker selectItemAtIndex:0];
    [self maybeEnableConvertButton];
    break;
  case ViewModeWithFile:
    [self showView:ViewRoot];
    [convertAVideo setStringValue:@"Ready To Convert!"];
    [self revealViewControls:viewMode];
    [self maybeEnableConvertButton];
    break;
  case ViewModeConverting:
    [self showView:ViewConverting];
    [self revealViewControls:viewMode];
    [convertingFilename setStringValue:
			  [self formatFilename:
				  [self fFMPEGOutputFile:filePath]
				maxLength:CONVERTING_MAX_FILE_LENGTH]];
    [self doFFMPEGConversion];
    break;
  case ViewModeFinished:
    [self showView:ViewRoot];
    [self revealViewControls:viewMode];
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
-(void) revealSubview:(NSView *)subview show:(BOOL)show {
  for(NSView *item in [rootView subviews]){
    if(item == subview && show == YES)
      return;
    if(item == subview && show == NO){
      [subview removeFromSuperview];
      return;
    }
  }
  if(show == YES)
    [rootView addSubview:subview];
}
-(void) revealViewControls:(ViewMode)viewMode{
  switch(viewMode) {
  case ViewModeInitial:
    [self revealSubview:convertAVideo      show:YES];
    [self revealSubview:dragAVideo         show:YES];
    [self revealSubview:chooseAFile1       show:YES];
    [self revealSubview:toSelectADifferent show:NO];
    [self revealSubview:chooseAFile2       show:NO];
    [self revealSubview:devicePicker       show:YES];
    [self revealSubview:convertButton      show:YES];
    [self revealSubview:filename           show:NO];
    [self revealSubview:finishedConverting show:NO];
    [self revealSubview:showFile           show:NO];
    break;
  case ViewModeWithFile:
    [self revealSubview:convertAVideo      show:YES];
    [self revealSubview:dragAVideo         show:NO];
    [self revealSubview:chooseAFile1       show:NO];
    [self revealSubview:toSelectADifferent show:YES];
    [self revealSubview:chooseAFile2       show:YES];
    [self revealSubview:devicePicker       show:YES];
    [self revealSubview:convertButton      show:YES];
    [self revealSubview:filename           show:YES];
    [self revealSubview:finishedConverting show:NO];
    [self revealSubview:showFile           show:NO];
    break;
  case ViewModeConverting:
    break;
  case ViewModeFinished:
    [self revealSubview:convertAVideo      show:NO];
    [self revealSubview:dragAVideo         show:YES];
    [self revealSubview:chooseAFile1       show:YES];
    [self revealSubview:toSelectADifferent show:NO];
    [self revealSubview:chooseAFile2       show:NO];
    [self revealSubview:devicePicker       show:YES];
    [self revealSubview:convertButton      show:YES];
    [self revealSubview:filename           show:NO];
    [self revealSubview:finishedConverting show:YES];
    [self revealSubview:showFile           show:YES];
    break;
  default:
    break;
  }
}

// Functions for root view
- (NSString *)formatFilename:(NSString *)inFile maxLength:(int)maxLength{
  NSString *outFile = [[inFile stringByAbbreviatingWithTildeInPath] lastPathComponent];
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
  [filename setStringValue:[self formatFilename:aFilename maxLength:DROPBOX_MAX_FILE_LENGTH]];
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
    [filename setStringValue:[self formatFilename:filePath maxLength:DROPBOX_MAX_FILE_LENGTH]];
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
  self.videoLength = 0;
  if(![[devicePicker titleOfSelectedItem] compare:@"Theora"])
    [self doSpeedTest];
  else
    [self doConversion];
}
-(void) doConversion {
  self.previousPercentDone = 0;
  [progressIndicator startAnimation:self];
  [progressIndicator setIndeterminate:YES];
  [percentDone setStringValue:@"Converting..."];
  [cancelButton setEnabled:YES];
  [self startAConversion:filePath];
}
-(void) convertingDone:(TaskEndStatus)status {
  [progressIndicator stopAnimation:self];
  videoLength = 0;
  percentPerOutputByte = 0;
  elapsedTime = 0;
  fileSize = 0;
  int iResponse;
  switch(status) {
  case EndStatusOK:
    [finishedConverting setStringValue:
			  [NSString stringWithFormat:@"Finished converting %@",
				    [self formatFilename:[self fFMPEGOutputFile:filePath]
					  maxLength:CONVERTING_DONE_MAX_FILE_LENGTH]]];
    [self setViewMode:ViewModeFinished];
    break;
  case EndStatusError:  
    iResponse = NSRunAlertPanel(@"Conversion Failed", @"Your file could not be converted.",
                                    @"OK", @"Show Output", nil);
    if(iResponse == NSAlertAlternateReturn)
      [fFMPEGOutputWindow makeKeyAndOrderFront:self];
  case EndStatusCancel:
    [self setViewMode:ViewModeWithFile];
    break;
  }
}
-(void) doSpeedTest {
  self.speedTestActive = YES;
  self.previousPercentDone = 0;
  [progressIndicator startAnimation:self];
  [progressIndicator setIndeterminate:YES];
  [percentDone setStringValue:@"Initializing..."];
  [cancelButton setEnabled:NO];
  [self.devicePicker selectItemAtIndex:1];
  [self startAConversion:filePath];
}
-(void) finishUpSpeedTest {
  self.speedTestActive = NO;
  [self.devicePicker selectItemAtIndex:3];
}
- (void)cwTaskWatcher:(CWTaskWatcher *)cwTaskWatcher ended:(TaskEndStatus)status {
  if(self.speedTestActive){
    [self finishUpSpeedTest];
    if(status == EndStatusOK){
      [self doConversion];
      return;
    }
  }
  [self convertingDone:status];
}
- (void)cwTaskWatcher:(CWTaskWatcher *)cwTaskWatcher updateString:(NSString *)output {
  static BOOL aboutToReadDuration = NO;

  [progressIndicator startAnimation:self];
  
  char buf[[output length]+1]; NSUInteger usedLength;
  [output getBytes:buf maxLength:[output length] usedLength:&usedLength
          encoding:NSASCIIStringEncoding options:NSStringEncodingConversionAllowLossy
          range:NSMakeRange(0,[output length]) remainingRange:nil];
  if(usedLength == 0)
    return;
  buf[usedLength] = 0;
  char *p = 0;
  if(self.videoLength == 0) {
    // see if "Duration:" string is in this input block, and if so, if
    // duration info is as well
    if(strlen(buf) >= strlen("Duration:")) {
      p = strstr(buf,"Duration:");
    if(p && strlen(p) >= strlen("Duration: ") + strlen("00:00:00")) {
      p += strlen("Duration: ");
      aboutToReadDuration = YES;
    }
    }
    if(p==0)
      p = buf;
    if(aboutToReadDuration){
      self.videoLength = 0;
      float components[3];
      sscanf(p,"%f:%f:%f",components,components+1, components+2);
      for(int i=2, mult=1; i>=0; i--, mult *= 60)
	self.videoLength += components[i]  * mult;
      aboutToReadDuration = NO;
      if(self.speedTestActive)
	[conversionWatcher requestFinishWithStatus:EndStatusOK];
      return;
    } else {
      // if duration info was not in this block, see if "Duration: string" was
      // (this is what usually happens)
      if(strlen(buf) >= strlen("Duration:") && strstr(buf,"Duration:"))
	aboutToReadDuration = YES;
    }
  }

  // time updates: time= for G1 and PSP, 
  float curTime = 0;
  if(strlen(buf) > strlen("time=")+1 && (p=strstr(buf,"time=")))
    sscanf(p+strlen("time="),"%f", &curTime);
  // "position": for Theora
  if(strlen(buf) > strlen("\"position\":")+1 && (p=strstr(buf,"\"position\":")))
    sscanf(p+strlen("\"position\":"),"%f", &curTime);
  // update percent done
  if(self.videoLength && !self.speedTestActive){
    if(curTime) {
      float percent = curTime / self.videoLength * 100;
      if(previousPercentDone && percent - previousPercentDone > 50)
        percent = previousPercentDone;
      if(percent > 100) percent = 99;
      previousPercentDone = percent;
      [progressIndicator setIndeterminate:NO];
      [progressIndicator setDoubleValue:percent];
      [percentDone setStringValue:[NSString stringWithFormat:@"%i%% done",(int)percent]];
    }
  }
}
- (void)cwTaskWatcher:(CWTaskWatcher *)cwTaskWatcher updateFileInfo:(NSDictionary *)dict {
  self.fileSize = [[dict objectForKey:@"filesize"] intValue];;
  self.elapsedTime = [[dict objectForKey:@"elapsedTime"] floatValue];
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

