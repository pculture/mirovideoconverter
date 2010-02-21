//
//  ClickableText.h
//
//  Created by Ben Haller on Tue Jul 15 2003.
//
//  This code is hereby released into the public domain.  Do with it as you wish.
//

#import <AppKit/AppKit.h>


@interface NSColor (ClickableTextColors)

+ (NSColor *)basicClickableTextColor;
+ (NSColor *)trackingClickableTextColor;
+ (NSColor *)visitedClickableTextColor;

@end

@interface ClickableText : NSTextField
{
	BOOL beingClicked, beenClicked;
}

- (id)initWithFrame:(NSRect)frame;

@end
