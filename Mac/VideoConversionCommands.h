/* -*- mode: objc -*- */
//
//  VideoConversionComands.h
//  Miro Video Converter
//
//  Created by C Worth on 2/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern char *deviceNames[];
extern char *selectors[];
extern char *fileExtensions[];
extern char *converterExecutables[];

@interface VideoConversionCommands : NSObject {
}

-(int) deviceIndex:(NSString *)device;
-(NSString *) fFMPEGLaunchPathForDevice:(NSString *)device;
-(NSString *) fFMPEGOutputFileForFile:(NSString *)inputFile andDevice:(NSString *)device;
-(NSArray *) fFMPEGArgumentsForFile:(NSString *)file andDevice:(NSString *)device;
-(NSArray *) nexusArgsForFile:(NSString *)file andDevice:(NSString *)device;
-(NSArray *) dreamArgsForFile:(NSString *)file andDevice:(NSString *)device;
-(NSArray *) magicArgsForFile:(NSString *)file andDevice:(NSString *)device;
-(NSArray *) droidArgsForFile:(NSString *)file andDevice:(NSString *)device;
-(NSArray *) erisArgsForFile:(NSString *)file andDevice:(NSString *)device;
-(NSArray *) heroArgsForFile:(NSString *)file andDevice:(NSString *)device;
-(NSArray *) cliqArgsForFile:(NSString *)file andDevice:(NSString *)device;
-(NSArray *) beholdArgsForFile:(NSString *)file andDevice:(NSString *)device;
-(NSArray *) iPhoneArgsForFile:(NSString *)file andDevice:(NSString *)device;
-(NSArray *) ipodArgsForFile:(NSString *)file andDevice:(NSString *)device;
-(NSArray *) playstationArgsForFile:(NSString *)file andDevice:(NSString *)device;
-(NSArray *) theoraArgsForFile:(NSString *)file andDevice:(NSString *)device;
-(NSArray *) mp4ArgsForFile:(NSString *)file andDevice:(NSString *)device;
-(NSArray *) mp3ArgsForFile:(NSString *)file andDevice:(NSString *)device;

@end
