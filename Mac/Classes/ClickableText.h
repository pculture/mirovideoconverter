/* -*- mode: objc -*- */
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
