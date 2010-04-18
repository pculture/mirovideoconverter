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
//  RootViewController.m
//  Miro Video Converter
//
//  Created by C Worth on 2/18/10.
//

#import "RootViewController.h"
#import <Cocoa/Cocoa.h>
#import "ClickableText.h"
#import "DropBoxView.h"
#import "CWTaskWatcher.h"
#import "VideoConversionCommands.h"

#define DROPBOX_MAX_FILE_LENGTH 32
#define CONVERTING_MAX_FILE_LENGTH 45
#define CONVERTING_DONE_MAX_FILE_LENGTH 27
#define FORMAT_QUERY_SYNCHRONOUS 1
@implementation RootViewController
@synthesize checkForUpdates;
@synthesize rootView,convertAVideo,dragAVideo,chooseAFile1,toSelectADifferent,chooseAFile2;
@synthesize filePath,devicePicker,convertButton,filename,dropBox,window;
@synthesize finishedConverting,showFile;      
@synthesize convertingView,convertingFilename,percentDone,progressIndicator,cancelButton;
@synthesize fFMPEGOutputWindow,fFMPEGOutputTextView,conversionWatcher,speedFile;
@synthesize formatQueryActive,fileSize,elapsedTime,percentPerOutputByte,videoLength, previousPercentDone;
@synthesize video,ffmpegFinishedOkayBeforeError;

-(void) awakeFromNib {
  static BOOL firstTime = YES;
  if(firstTime){
    video = [[VideoConversionCommands alloc] init];
    [devicePicker setAutoenablesItems:NO];
    [devicePicker removeAllItems];
    [devicePicker addItemWithTitle:@"Pick a Device or Video Format"];
    int i=0, j=1;
    while(deviceNames[i++]){
      [[devicePicker menu] addItem:[NSMenuItem separatorItem]]; j++;
      [devicePicker addItemWithTitle:[NSString stringWithFormat:@"%s",deviceNames[i-1]]];
      NSMenuItem *item = [devicePicker itemAtIndex:j++];
      NSDictionary *attrib =
        [[NSDictionary alloc] initWithObjectsAndKeys:
                                [NSFont systemFontOfSize:14.0], NSFontAttributeName,
                              [NSColor blackColor], NSForegroundColorAttributeName,
                              [NSNumber numberWithFloat:-4], NSStrokeWidthAttributeName, nil];
      NSAttributedString *title =
        [[NSAttributedString alloc]
          initWithString:[NSString stringWithFormat:@"%s",deviceNames[i-1]]
          attributes:attrib];
      [attrib release];
      [item setAttributedTitle:title];
      [item setEnabled:NO];
      while(deviceNames[i++]){
        [devicePicker addItemWithTitle:[NSString stringWithFormat:@"%s",deviceNames[i-1]]];
        j++;
      }
    }
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
    break;
  case ViewModeWithFile:
    [self showView:ViewRoot];
    [convertAVideo setStringValue:@"Ready To Convert!"];
    [self revealViewControls:viewMode];
    break;
  case ViewModeConverting:
    [self showView:ViewConverting];
    [self revealViewControls:viewMode];
    NSString *op = [video fFMPEGOutputFileForFile:filePath andDevice:[devicePicker titleOfSelectedItem]];
    [convertingFilename setStringValue:[self formatFilename:op maxLength:CONVERTING_MAX_FILE_LENGTH]];
    [self doFFMPEGConversion];
    break;
  case ViewModeFinished:
    [self showView:ViewRoot];
    [self revealViewControls:viewMode];
    [devicePicker selectItemAtIndex:0];
    break;
  default:
    break;
  }
  currentViewMode = viewMode;
  [self maybeEnableConvertButton];
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
  if([devicePicker indexOfSelectedItem] != 0 &&
     [self.rootView.subviews containsObject:filename])
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
  [self doFormatQuery];
}
-(void) doFormatQuery {
  self.formatQueryActive = YES;
  video.screenSize = CGSizeMake(0,0);
  self.previousPercentDone = 0;
  [progressIndicator startAnimation:self];
  [progressIndicator setIndeterminate:YES];
  [percentDone setStringValue:@"Initializing..."];
  [cancelButton setEnabled:NO];
  [self startAConversion:filePath forDevice:nil synchronous:FORMAT_QUERY_SYNCHRONOUS];
}
-(void) finishUpFormatQuery {
  self.formatQueryActive = NO;
}
-(void) doConversion {
  self.previousPercentDone = 0;
  [progressIndicator startAnimation:self];
  [progressIndicator setIndeterminate:YES];
  [percentDone setStringValue:@"Converting..."];
  [cancelButton setEnabled:YES];
  [self startAConversion:filePath forDevice:[devicePicker titleOfSelectedItem] synchronous:NO];
}
-(void) startAConversion:(NSString *)file forDevice:(NSString *)device synchronous:(BOOL)sync {
  self.ffmpegFinishedOkayBeforeError = NO;
  // initialize textbox for FFMPEG output window
  NSTextStorage *storage = [[[fFMPEGOutputTextView textContainer] textView] textStorage];
  NSAttributedString *string =
    [[NSAttributedString alloc]
      initWithString:[NSString stringWithFormat:@"%@ %@\n",[[video fFMPEGLaunchPathForDevice:device] lastPathComponent],
                               [[video fFMPEGArgumentsForFile:file andDevice:device] componentsJoinedByString:@" "]]];
  [storage setAttributedString:string];
  [string release];
  NSString *path = [video fFMPEGLaunchPathForDevice:device];
  NSArray *args = [video fFMPEGArgumentsForFile:file andDevice:device];
  if(!sync) {
    CWTaskWatcher *aWatcher = [[CWTaskWatcher alloc] init];
    self.conversionWatcher = aWatcher;
    [aWatcher release];
    conversionWatcher.delegate = self;
    conversionWatcher.textStorage = storage;
    [conversionWatcher startTask:path withArgs:args 
                       andProgressFile:[video fFMPEGOutputFileForFile:file andDevice:device]];
  } else {
    int status;
    NSString *output = [CWTask performSynchronousTask:path withArgs:args andReturnStatus:&status];
    [self cwTaskWatcher:nil updateString:output];
    [self cwTaskWatcher:nil ended:status];
  }
}
-(void) convertingDone:(TaskEndStatus)status {
  [progressIndicator stopAnimation:self];
  videoLength = 0;
  percentPerOutputByte = 0;
  elapsedTime = 0;
  fileSize = 0;
  if(status == EndStatusError && self.ffmpegFinishedOkayBeforeError == YES)
    status = EndStatusOK;
  NSString *file = [video fFMPEGOutputFileForFile:filePath andDevice:[devicePicker titleOfSelectedItem]];
  int iResponse;
  switch(status) {
  case EndStatusOK:
    [finishedConverting setStringValue:
			  [NSString stringWithFormat:@"Finished converting %@",
				    [self formatFilename:file maxLength:CONVERTING_DONE_MAX_FILE_LENGTH]]];
    [self setViewMode:ViewModeFinished];
    break;
  case EndStatusError:
    if([[NSFileManager defaultManager] isReadableFileAtPath:file])
      [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
    iResponse = NSRunAlertPanel(@"Conversion Failed", @"Your file could not be converted.",
                                    @"OK", @"Show Output", nil);
    if(iResponse == NSAlertAlternateReturn)
      [fFMPEGOutputWindow makeKeyAndOrderFront:self];
  case EndStatusCancel:
    if([[NSFileManager defaultManager] isReadableFileAtPath:file])
      [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
    [self setViewMode:ViewModeWithFile];
    break;
  }
}
- (void)cwTaskWatcher:(CWTaskWatcher *)cwTaskWatcher ended:(TaskEndStatus)status {
  if(self.formatQueryActive){
    [self finishUpFormatQuery];
    [self doConversion];
    return;
  }
  [self convertingDone:status];
}
- (void)cwTaskWatcher:(CWTaskWatcher *)cwTaskWatcher updateFileInfo:(NSDictionary *)dict {
  self.fileSize = [[dict objectForKey:@"filesize"] intValue];;
  self.elapsedTime = [[dict objectForKey:@"elapsedTime"] floatValue];
}
- (NSString *)cwTaskWatcher:(CWTaskWatcher *)cwTaskWatcher censorOutput:(NSString *)input {
  char *p = (char *)[input UTF8String], *q;
  char *str = malloc([input length] + 10);
  strncpy(str,p,[input length]);
  if(strlen(str) > strlen("pointer being freed was not allocated"))
    q = strstr(str,"pointer being freed was not allocated");
  else
    return input;
  if(!q) return input;
  for(;q >= str && *q != '\n'; q--);
  if(q==str) sprintf(q,"[sic]\n");
  else sprintf(q+1,"[sic]\n");
  NSString *output = [NSString stringWithFormat:@"%s",str];
  free(str);
  return output;
}

- (int)getNumber:(float *)number fromBuffer:(char *)buf withError:(BOOL *)error {
  if(strlen(buf) == 0) {
    *error = YES;
    return 0;
  }
  char *buf2 = malloc(strlen(buf)+1);
  memcpy(buf2,buf,strlen(buf));
  int numStart = -1;
  for(int i=0; i<strlen(buf); i++)
    if(numStart == -1){
      if(buf[i] >= '0' && buf[i] <= '9')
        numStart = i;
    } else {
      if(!(buf[i] >= '0' && buf[i] <= '9')){
        buf2[i] = 0;
        sscanf(buf2+numStart,"%f",number);
        *error = NO;
        return i;
      }
    }
  *error = YES;
  return 0;
}

- (CGSize)getScreenSizeFromBuffer:(char *)buf {
  CGSize size = CGSizeMake(0,0); 
  // Look for length after "Duration:" string
  char durStr[256],*p; strcpy(durStr,"Duration:");
  if(strlen(buf) >= strlen(durStr)) {
    p = strstr(buf,durStr);
    if(p && strlen(p) >= strlen(durStr) + 9) {
      p += strlen(durStr) + 1;
      int i = (int)(p-buf); float number; BOOL error = NO;
      while(!error && i < strlen(buf)){
        i += [self getNumber:&number fromBuffer:buf+i withError:&error];
        if( ! (error || i > strlen(buf) - 2 || buf[i] != 'x') ){
          float width = number;
          i++;
          if(buf[i] >='0' && buf[i]<='9'){
            i += [self getNumber:&number fromBuffer:buf+i withError:&error];
            if(!error){
              size.width = width;
              size.height = number;
              return size;
            }
          }
        }
      }
    }
  }
  return size;
}

- (void)cwTaskWatcher:(CWTaskWatcher *)cwTaskWatcher updateString:(NSString *)output {

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
    char durStr[256];
    if(![[devicePicker titleOfSelectedItem] compare:@" Theora"])
      strcpy(durStr,"\"duration\":");
    else
      strcpy(durStr,"Duration:");
    // see if durStr string is in this input block
    if(strlen(buf) >= strlen(durStr)) {
      p = strstr(buf,durStr);
      if(p && strlen(p) >= strlen(durStr) + 9) {
        p += strlen(durStr) + 1;
        self.videoLength = 0;
        if(![[devicePicker titleOfSelectedItem] compare:@" Theora"]) {
          //theora
          float dur;
          sscanf(p,"%f",&dur);
          self.videoLength = dur;
        } else {
          //ffmpeg
          float components[3];
          sscanf(p,"%f:%f:%f",components,components+1, components+2);
          for(int i=2, mult=1; i>=0; i--, mult *= 60)
            self.videoLength += components[i]  * mult;
        }
      }
    }
  }

  // time updates: time= for ffmpeg
  float curTime = 0;
  if(strlen(buf) > strlen("time=")+1 && (p=strstr(buf,"time=")))
    sscanf(p+strlen("time="),"%f", &curTime);
  // "position": for ffpeg2theora
  if(strlen(buf) > strlen("\"position\":")+1 && (p=strstr(buf,"\"position\":")))
    sscanf(p+strlen("\"position\":"),"%f", &curTime);
  // now update percent done
  if(self.videoLength && !self.formatQueryActive){
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

  // video resolution, appears shortly after Duration string in ffmpeg output:
  if(self.formatQueryActive && video.screenSize.width == 0){
    CGSize size = [self getScreenSizeFromBuffer:buf];
    if(size.width > 0 && size.height > 0) {
      size = [video fitScreenSize:size toDevice:[devicePicker titleOfSelectedItem]];
      if(size.width > 0 && size.height > 0)
        video.screenSize = size;
    }
  }

  // Check for libxvid malloc error at end, may have completed successfully
  if(strlen(buf) > strlen("muxing overhead") && (p=strstr(buf,"muxing overhead")))
    self.ffmpegFinishedOkayBeforeError = YES;
  return;
}
@end

