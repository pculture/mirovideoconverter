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
extern CGSize screenSizes[];

@interface VideoConversionCommands : NSObject {
  CGSize screenSize;
}
@property(assign) CGSize screenSize;

-(int) deviceIndex:(NSString *)device;
-(NSString *) outputVideoSizeStringForDevice:(NSString *)device;
-(NSString *) fFMPEGLaunchPathForDevice:(NSString *)device;
-(NSString *) fFMPEGOutputFileForFile:(NSString *)inputFile andDevice:(NSString *)device;
-(NSArray *) fFMPEGArgumentsForFile:(NSString *)file andDevice:(NSString *)device;
-(NSArray *) formatQueryArgsForFile:(NSString *)file;
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
-(CGSize) fitScreenSize:(CGSize)size toDevice:(NSString *)device;
@end
