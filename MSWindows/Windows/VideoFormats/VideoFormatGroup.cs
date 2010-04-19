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

﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Mirosubs.Converter.Windows.VideoFormats {
    class VideoFormatGroup {
        public readonly static VideoFormatGroup Formats =
            new VideoFormatGroup("Formats", 1);
        public readonly static VideoFormatGroup Android =
            new VideoFormatGroup("Devices: Android", 2);
        public readonly static VideoFormatGroup Apple =
            new VideoFormatGroup("Devices: Apple", 3);
        public readonly static VideoFormatGroup Other =
            new VideoFormatGroup("Devices: Other", 4);

        private string displayName;
        private int order;
        private VideoFormatGroup(string displayName, int order) {
            this.displayName = displayName;
            this.order = order;
        }
        public string DisplayName {
            get { return displayName; }
        }
        public int Order {
            get { return order; }
        }
    }
}
