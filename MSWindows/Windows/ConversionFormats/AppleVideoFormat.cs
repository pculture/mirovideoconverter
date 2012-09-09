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
using System.Diagnostics;

namespace Mirosubs.Converter.Windows.ConversionFormats {
    class AppleVideoFormat : ConversionFormat {
        private static readonly VideoSize DEFAULT_DIM =
            new VideoSize() { Width = 480, Height = 320 };
        private static readonly VideoSize IPAD_DIM =
            new VideoSize() { Width = 1024, Height = 768 };
        private static readonly VideoSize APPLE_TV =
            new VideoSize() { Width = 1280, Height = 720 };
        private static readonly VideoSize APPLE_UNIVERSAL =
            new VideoSize() { Width = 1280, Height = 720 };

        public readonly static ConversionFormat appleUniversal =
            new AppleVideoFormat("Apple Universal", "appleuniversal", APPLE_UNIVERSAL);
        public readonly static ConversionFormat iPhone =
            new AppleVideoFormat("iPhone", "iphone");
        public readonly static ConversionFormat iPad =
            new AppleVideoFormat("iPad", "ipad", IPAD_DIM);
        public readonly static ConversionFormat iPodTouch =
            new AppleVideoFormat("iPod Touch", "ipodtouch");
        public readonly static ConversionFormat iPodNano =
            new AppleVideoFormat("iPod Nano", "ipodnano");
        public readonly static ConversionFormat iPodClassic =
            new AppleVideoFormat("iPod Classic", "ipodclassic");
        public readonly static ConversionFormat appleTV =
            new AppleVideoFormat("Apple TV", "appletv", APPLE_TV);

        // TODO: Some petit duplication has arisen between this class 
        // and AndroidVideoFormat. Maybe fix that.

        private VideoSize size;

        private AppleVideoFormat(string displayName, string filePart)
            : this(displayName, filePart, DEFAULT_DIM) {
        }
        private AppleVideoFormat(string displayName, string filePart, VideoSize size)
            : base(displayName, filePart, "mp4", VideoFormatGroup.Apple) {
            this.size = size;
        }
        public override string GetArguments(string inputFileName, string outputFileName) {
            string sizeArg = GetSizeArgument(inputFileName, this.size);
            return string.Format(
                "-i \"{0}\" -acodec aac -ab 160k {1} -vcodec libx264 -vpre slow " +
                "-vpre ipod640 -b:v 1200k -f mp4 -threads 0 -strict experimental \"{2}\"",
                inputFileName, sizeArg, outputFileName);
        }
        public override IVideoConverter MakeConverter(string fileName) {
            return new FFMPEGVideoConverter(fileName, this);
        }
    }
}
