//
//  Miro_Video_ConverterAppDelegate.h
//  Miro Video Converter
//
//  Created by C Worth on 2/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class RootViewController;

//@interface Miro_Video_ConverterAppDelegate : NSObject <NSApplicationDelegate> {  // 10.6
@interface Miro_Video_ConverterAppDelegate : NSObject {  // 10.5
    NSWindow *window;
	RootViewController *rootViewController;
}

@property (assign) IBOutlet NSWindow *window;
@property (retain) IBOutlet RootViewController *rootViewController;

@end
