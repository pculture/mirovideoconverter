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

@implementation RootViewController

@synthesize dragAVideoLabel,chooseAFile1,toSelectADifferent,chooseAFile2,devicePicker,convertButton,filename;

-(IBAction) convertButtonClick:(id)sender {

  self.chooseAFile1.alphaValue = 0;
}
-(IBAction) chooseAFile:(id)sender {
	self.convertButton.alphaValue = 0;	
}
-(IBAction) fileDrugToBox:(id)sender {

}
-(void) setViewMode:(ViewMode)viewMode{
	switch(viewMode) {
		case initialView:
			toSelectADifferent.alphaValue = 0;
			chooseAFile2.alphaValue = 0;
			filename.alphaValue = 0;
			[convertButton setTitle:@"Convert"];
			break;
		default:
			break;

	}
}


@end
