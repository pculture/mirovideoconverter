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
    class AndroidVideoFormat : VideoFormat {

        private static readonly VideoSize DEFAULT_DIM = 
            new VideoSize() { Width = 480, Height = 320 };
        private static readonly VideoSize NEXUS_DIM =
            new VideoSize() { Width = 800, Height = 480 };
        private static readonly VideoSize DROID_DIM =
            new VideoSize() { Width = 854, Height = 480 };

        public readonly static VideoFormat G1 =
            new AndroidVideoFormat("G1", "g1");
        public readonly static VideoFormat NexusOne =
            new AndroidVideoFormat("Nexus One", "nexusone",
                NEXUS_DIM);
        public readonly static VideoFormat MagicMyTouch =
            new AndroidVideoFormat("Magic / myTouch", "magic");
        public readonly static VideoFormat Droid =
            new AndroidVideoFormat("Droid", "droid", 
                DROID_DIM);
        public readonly static VideoFormat ErisDesire =
            new AndroidVideoFormat("Eris / Desire", "eris");
        public readonly static VideoFormat Hero =
            new AndroidVideoFormat("Hero", "hero");
        public readonly static VideoFormat CliqDEXT =
            new AndroidVideoFormat("Cliq / DEXT", "cliq");
        public readonly static VideoFormat BeholdII =
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
            VideoParameters parms =
                VideoParameterOracle.GetParameters(inputFileName);
            VideoSize size = parms == null ? null : parms.VideoSize;
            string sizeArg = "";
            if (size != null && size.CompareTo(this.size) > 0) {
                float widthRatio = (float)size.Width / this.size.Width;
                float heightRatio = (float)size.Height / this.size.Height;
                float ratio = Math.Max(widthRatio, heightRatio);
                sizeArg = string.Format("-s {0}x{1}",
                    (int)(size.Width / ratio), 
                    (int)(size.Height / ratio));
            }
            return string.Format(
                "-i \"{0}\" -y -f mp4 -vcodec mpeg4 -sameq {1} " +
                "-acodec aac -ab 48000 -r 18 \"{2}\"",
                inputFileName, sizeArg, outputFileName);
        }

        public override VideoConverter MakeConverter(string fileName) {
            return new FFMPEGVideoConverter(fileName, this);
        }
    }
}
