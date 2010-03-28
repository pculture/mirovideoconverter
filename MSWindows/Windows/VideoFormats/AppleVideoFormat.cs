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
using Mirosubs.Converter.Windows.Process;

namespace Mirosubs.Converter.Windows.VideoFormats {
    class AppleVideoFormat : VideoFormat {
        public readonly static VideoFormat iPhone =
            new AppleVideoFormat("iPhone", "iphone");
        public readonly static VideoFormat iPodTouch =
            new AppleVideoFormat("iPod Touch", "ipodtouch");
        public readonly static VideoFormat iPodNano =
            new AppleVideoFormat("iPod Nano", "ipodnano");
        public readonly static VideoFormat iPodClassic =
            new AppleVideoFormat("iPod Classic", "ipodclassic");

        private AppleVideoFormat(string displayName, string filePart)
            : base(displayName, filePart, "mp4", VideoFormatGroup.Apple) {
        }
        public override string GetArguments(string inputFileName, string outputFileName) {
            return string.Format(
                "-i \"{0}\"  -acodec aac -ab 96000 -vcodec mpeg4 -b 1200kb " +
                "-mbd 2 -cmp 2 -subcmp 2 -s 480x320 -r 20 \"{1}\"",
                inputFileName, outputFileName);
        }
        public override VideoConverter MakeConverter(string fileName) {
            return new FFMPEGVideoConverter(fileName, this);
        }
    }
}
