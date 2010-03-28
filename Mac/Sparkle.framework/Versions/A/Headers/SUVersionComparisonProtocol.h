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
//  SUVersionComparisonProtocol.h
//  Sparkle
//
//  Created by Andy Matuschak on 12/21/07.
//  Copyright 2007 Andy Matuschak. All rights reserved.
//

#ifndef SUVERSIONCOMPARISONPROTOCOL_H
#define SUVERSIONCOMPARISONPROTOCOL_H

/*!
    @protocol
    @abstract    Implement this protocol to provide version comparison facilities for Sparkle.
*/
@protocol SUVersionComparison

/*!
    @method     
    @abstract   An abstract method to compare two version strings.
    @discussion Should return NSOrderedAscending if b > a, NSOrderedDescending if b < a, and NSOrderedSame if they are equivalent.
*/
- (NSComparisonResult)compareVersion:(NSString *)versionA toVersion:(NSString *)versionB;

@end

#endif
