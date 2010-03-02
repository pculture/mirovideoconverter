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
@synthesize convertingView,convertingFilename,percentDone,progressIndicator,cancelButton,fFMPEGButton;
@synthesize fFMPEGOutputWindow,fFMPEGOutputTextView,conversionTask;
@synthesize conversionTimer,delayTimer,speedFile,conversionTime;

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
-(void) doFFMPEGConversion {
  [self doSpeedTest];
}
/**
  setup FFMPEG task with an output pipe
  request background read and notify
*/
#define TEST_SIZE 1024*384
-(void) doSpeedTest {
  [cancelButton setEnabled:NO];
  [fFMPEGButton setEnabled:NO];
  [percentDone setStringValue:@"Initializing..."];

  // smaller test file
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
      // remove speedTest output file
      NSString *outputFile = [self fFMPEGOutputFile:speedFile];
      if ( [[NSFileManager defaultManager] isReadableFileAtPath:outputFile] )
	[[NSFileManager defaultManager] removeItemAtPath:outputFile error:nil];
      //setup task
      NSTask *aTask =
	[self setupTask:[self fFMPEGLaunchPath]
	      andArguments:[self fFMPEGArguments:speedFile]
	      andOutPipe:nil
	      andErrPipe:nil
	      andTerminationSelector:nil];
      self.conversionTask = aTask;
      [aTask release];
      
      [aTask launch];

      self.conversionTime = [NSDate date];
      self.conversionTimer = 
	[NSTimer scheduledTimerWithTimeInterval:0.5 target:self
		 selector:@selector(monitorSpeedTest:)
		 userInfo:nil
		 repeats:YES];
      
    } else
    [self doConversion];
  } else
    [self doConversion];
}    
-(void) monitorSpeedTest:(NSTimer *)timer {
  static int oldSize = 0;

  int fileSize = 0;
  EndSpeedTest endTest = WAITING;
  if(![conversionTask isRunning])
    endTest = TASKDONE;   // task ended
  else {
    NSString *outputFile = [self fFMPEGOutputFile:speedFile];
    if (![[NSFileManager defaultManager] isReadableFileAtPath:outputFile]) {
      if([conversionTime timeIntervalSinceNow]*(-1) > 3.0)
	endTest = ERROR; // file not created for 3 sec after start
    } else {
      fileSize = (int) [[[NSFileManager defaultManager]
			  attributesOfItemAtPath:outputFile error:nil]
			 fileSize];
      if(oldSize && fileSize == oldSize &&
	 [conversionTime timeIntervalSinceNow]*(-1) > 3.0)
	endTest = ERROR; // file hung for 3 sec since last update
    }
  }

  if(endTest == WAITING){
    if(oldSize != fileSize){
      oldSize = fileSize;
      self.conversionTime = [NSDate date];
    }
  } else {
    [timer invalidate];
    oldSize = 0;
    [self speedTestCompleted:endTest];
  }
}
-(void) speedTestCompleted:(EndSpeedTest) endTest {
  if([conversionTask isRunning])
    [conversionTask terminate];
  self.conversionTimer = 0;
  self.conversionTask = 0;

  if(endTest == ERROR) {
    fFMPEGStatus = FFMPEGStatusError;
  } else {
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
    NSString *outputFile = [self fFMPEGOutputFile:speedFile];
    if([[NSFileManager defaultManager] isReadableFileAtPath:outputFile]){
      outputSpeedTestFileSize =
	[[[NSFileManager defaultManager]
	   attributesOfItemAtPath:outputFile error:nil]
	  fileSize];
    }
    if(inputFileSize && inputSpeedTestFileSize && outputSpeedTestFileSize)
      percentPerOutputByte = (float)100 /
	((float)inputFileSize * outputSpeedTestFileSize/inputSpeedTestFileSize);
    else
      percentPerOutputByte = 0;
  }

  // remove speedTest files
  if ( [[NSFileManager defaultManager] isReadableFileAtPath:speedFile] )
    [[NSFileManager defaultManager] removeItemAtPath:speedFile error:nil];
  NSString *outputFile = [self fFMPEGOutputFile:speedFile];
  if ( [[NSFileManager defaultManager] isReadableFileAtPath:outputFile] )
    [[NSFileManager defaultManager] removeItemAtPath:outputFile error:nil];

  if(endTest == ERROR)
    [self convertingDone:nil];
  else
    [self doConversion];
}
-(void) doConversion {
  // remove output file
  NSString *outputFile = [self fFMPEGOutputFile:filePath];
  if ( [[NSFileManager defaultManager] isReadableFileAtPath:outputFile] )
    [[NSFileManager defaultManager] removeItemAtPath:outputFile error:nil];

  // initialize textbox for FFMPEG output window
  NSTextStorage *storage = [[[fFMPEGOutputTextView textContainer] textView] textStorage];
  NSAttributedString *string = [[NSAttributedString alloc] initWithString:@""];
  [storage setAttributedString:string];
  [string release];
  
  // start conversion
  NSPipe *outputPipe = [NSPipe pipe];

  NSTask *aTask =
    [self setupTask:[self fFMPEGLaunchPath]
	  andArguments:[self fFMPEGArguments:filePath]
	  andOutPipe:outputPipe
	  andErrPipe:outputPipe
	  andTerminationSelector:@selector(conversionTaskCompleted:)];
  self.conversionTask = aTask;
  [aTask release];
  
  NSFileHandle *output = [outputPipe fileHandleForReading];
  [[NSNotificationCenter defaultCenter]
    addObserver:self selector:@selector(conversionTaskDataAvailable:)
    name:NSFileHandleReadCompletionNotification object:output];
  
  fFMPEGStatus = FFMPEGStatusConverting;
  [aTask launch];

  [output readInBackgroundAndNotify];

  self.conversionTimer = 
    [NSTimer scheduledTimerWithTimeInterval:0.2 target:self
	     selector:@selector(updateDonePercentage:)
	     userInfo:nil
	     repeats:YES];

  [cancelButton setEnabled:YES];
  [fFMPEGButton setEnabled:YES];
}
-(NSTask *) setupTask:(NSString *)path andArguments:(NSArray *)arguments
	   andOutPipe:(NSPipe *)outPipe andErrPipe:(NSPipe *)errPipe
           andTerminationSelector:(SEL)selector {

  NSTask *aTask = [[NSTask alloc] init];

  [aTask setLaunchPath:path];
  [aTask setArguments:arguments];

  NSMutableDictionary *environment =
    [[NSMutableDictionary alloc]
      initWithDictionary:[[NSProcessInfo processInfo] environment]];
  [environment setObject:@"YES" forKey:@"NSUnbufferedIO"];
  [aTask setEnvironment:environment];
  [environment release];

  if(outPipe)
    [aTask setStandardError:outPipe];
  if(errPipe)
    [aTask setStandardError:errPipe];

  if(selector)
    [[NSNotificationCenter defaultCenter]
      addObserver:self selector:selector
      name:NSTaskDidTerminateNotification object:aTask];

  return aTask;
}
-(void) conversionTaskDataAvailable:(NSNotification *)note {
  static int textPosition = 0;
  NSTextStorage *storage = [[[fFMPEGOutputTextView textContainer] textView] textStorage];
  NSData *data = [[note userInfo] objectForKey:NSFileHandleNotificationDataItem];
  if(data && [data length])
    [storage replaceCharactersInRange:NSMakeRange([storage length], 0)
	     withString:[NSString stringWithUTF8String:[data bytes]]];
  textPosition = [storage length];
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
  // Invalidate old timer and Schedule new timer to allow final output to pipe to window
  if([self.conversionTimer isValid])
    [self.conversionTimer invalidate];
  self.delayTimer = 
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
  self.conversionTask = 0;
  NSString *outputFile = [self fFMPEGOutputFile:filePath];
  switch(fFMPEGStatus) {
  case FFMPEGStatusDone:
    [finishedConverting setStringValue:[NSString stringWithFormat:@"Finished converting %@",
						 [convertingFilename stringValue]]];
    [self setViewMode:ViewModeFinished];
    break;
  case FFMPEGStatusError:  
    NSRunAlertPanel(@"Conversion Failed", @"Your file could not be converted.", @"OK", nil, nil);
  case FFMPEGStatusCancelled:
    if ( [[NSFileManager defaultManager] isReadableFileAtPath:outputFile] )
      [[NSFileManager defaultManager] removeItemAtPath:outputFile error:nil];
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
  // may have completed conversion already (?)
  if(currentViewMode == ViewModeConverting)
    switch(iResponse) {
    case NSAlertDefaultReturn:
      break;
    case NSAlertAlternateReturn:
      fFMPEGStatus = FFMPEGStatusCancelled;
      if([conversionTimer isValid])
	[conversionTimer invalidate];
      [percentDone setStringValue:@"Cancelling..."];
      if([conversionTask isRunning])
	[conversionTask terminate];
      break;
    default:
      break;
    }
}
-(void) updateDonePercentage:(NSTimer *)timer {
  NSString *outputFile = [self fFMPEGOutputFile:filePath];
  if (percentPerOutputByte &&
      [[NSFileManager defaultManager] isReadableFileAtPath:outputFile]){
    int fileSize = [[[NSFileManager defaultManager]
		      attributesOfItemAtPath:outputFile error:nil]
		     fileSize];
    double percent = percentPerOutputByte * fileSize;
    percent = (percent > 99.1 ? 99 : percent);
    [progressIndicator setIndeterminate:NO];
    [progressIndicator setDoubleValue:percent];
    [percentDone setStringValue:[NSString stringWithFormat:@"%i%% done",(int)percent]];
  } else {
    [progressIndicator setIndeterminate:YES];
    [percentDone setStringValue:@"Converting..."];
  }    
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
    [args addObject:@"-threads"];
    [args addObject:@"0"];
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
