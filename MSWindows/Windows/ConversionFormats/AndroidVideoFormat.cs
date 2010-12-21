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

namespace Mirosubs.Converter.Windows.ConversionFormats {
    class AndroidVideoFormat : ConversionFormat {

        private static readonly VideoSize DEFAULT_DIM = 
            new VideoSize() { Width = 480, Height = 320 };
        private static readonly VideoSize NEXUS_DIM =
            new VideoSize() { Width = 800, Height = 480 };
        private static readonly VideoSize DROID_DIM =
            new VideoSize() { Width = 854, Height = 480 };

        public readonly static ConversionFormat G1 =
            new AndroidVideoFormat("G1", "g1");
        public readonly static ConversionFormat NexusOne =
            new AndroidVideoFormat("Nexus One", "nexusone",
                NEXUS_DIM);
        public readonly static ConversionFormat MagicMyTouch =
            new AndroidVideoFormat("Magic / myTouch", "magic");
        public readonly static ConversionFormat Droid =
            new AndroidVideoFormat("Droid", "droid", 
                DROID_DIM);
        public readonly static ConversionFormat ErisDesire =
            new AndroidVideoFormat("Eris / Desire", "eris");
        public readonly static ConversionFormat Hero =
            new AndroidVideoFormat("Hero", "hero");
        public readonly static ConversionFormat CliqDEXT =
            new AndroidVideoFormat("Cliq / DEXT", "cliq");
        public readonly static ConversionFormat BeholdII =
            new AndroidVideoFormat("Behold II", "behold");

        private VideoSize size;

        private AndroidVideoFormat(string displayName, string filePart)
            : this(displayName, filePart, DEFAULT_DIM) {
        }

        private AndroidVideoFormat(string displayName,
            string filePart, VideoSize size) 
            : base(displayName, filePart, "mp4", VideoFormatGroup.Android) {
            this.size = size;
        }

        public override string GetArguments(string inputFileName, string outputFileName) {
            string sizeArg = GetSizeArgument(inputFileName, this.size);
            return string.Format(
                "-i \"{0}\" -y -acodec aac -strict experimental -ab 160k {1} -vcodec libx264 " +
                "-vpre slow -crf 22 -f mp4 -threads 0 \"{2}\"",
                inputFileName, sizeArg, outputFileName);
        }

        public override IVideoConverter MakeConverter(string fileName) {
            return new FFMPEGVideoConverter(fileName, this);
        }
    }
}
