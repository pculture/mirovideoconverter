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
//  ClickableText.m
//
//  Created by Ben Haller on Tue Jul 15 2003.
//
//  This code is hereby released into the public domain.  Do with it as you wish.
//

#import "ClickableText.h"


@implementation NSColor (ClickableTextColors)

+ (NSColor *)basicClickableTextColor
{
	static NSColor *cachedColor = nil;
	
	if (!cachedColor)
		cachedColor = [[NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:1.0] retain];
	
	return cachedColor;
}

+ (NSColor *)trackingClickableTextColor
{
	static NSColor *cachedColor = nil;
	
	if (!cachedColor)
		cachedColor = [[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:1.0 alpha:1.0] retain];
	
	return cachedColor;
}

+ (NSColor *)visitedClickableTextColor
{
	static NSColor *cachedColor = nil;
	
	if (!cachedColor)
		cachedColor = [[NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:1.0] retain];
	
	return cachedColor;
}

@end

@implementation ClickableText

- (void)finishInitialization
{
	[self setBordered:NO];
	[self setBezeled:NO];
	[self setDrawsBackground:NO];
	[self setEditable:NO];
	[self setSelectable:NO];
	[self setEnabled:YES];
	[self setTextColor:[NSColor basicClickableTextColor]];
}

- (id)initWithCoder:(NSCoder *)decoder
{
	if (self = [super initWithCoder:decoder])
	{
		[self finishInitialization];
	}
	
	return self;
}

- (id)initWithFrame:(NSRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		[self finishInitialization];
	}
	
	return self;
}

- (void)mouseDown:(NSEvent *)event
{
	BOOL mouseInside = YES;
	
	beingClicked = YES;
	[self setTextColor:[NSColor trackingClickableTextColor]];
	
	while (beingClicked && (event = [[self window] nextEventMatchingMask:(NSLeftMouseUpMask | NSLeftMouseDraggedMask)]))
	{
		NSEventType type = [event type];
		NSPoint location = [event locationInWindow];
		
		location = [self convertPoint:location fromView:nil];
		mouseInside = NSPointInRect(location, [self bounds]);
		
		if (mouseInside)
			[self setTextColor:[NSColor trackingClickableTextColor]];
		else if (beenClicked)
			[self setTextColor:[NSColor visitedClickableTextColor]];
		else
			[self setTextColor:[NSColor basicClickableTextColor]];
		
		if (type == NSLeftMouseUp)
			beingClicked = NO;
	}
	
	if (mouseInside)
	{
		beenClicked = YES;
		[self setTextColor:[NSColor visitedClickableTextColor]];
		[self sendAction:[self action] to:[self target]];
	}
}

@end
