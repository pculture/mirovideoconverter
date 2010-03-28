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
    abstract class VideoFormat {
        public static readonly VideoFormat[] All = new VideoFormat[] { 
            AndroidVideoFormat.G1, 
            PSPVideoFormat.PSP, 
            TheoraVideoFormat.Theora, 
            AndroidVideoFormat.NexusOne, 
            AndroidVideoFormat.MagicMyTouch, 
            AndroidVideoFormat.Droid, 
            AndroidVideoFormat.ErisDesire,
            AndroidVideoFormat.Hero, 
            AndroidVideoFormat.CliqDEXT, 
            AndroidVideoFormat.BeholdII, 
            AppleVideoFormat.iPhone, 
            AppleVideoFormat.iPodTouch, 
            AppleVideoFormat.iPodNano, 
            AppleVideoFormat.iPodClassic
        };

        private string displayName;
        private string filePart;
        private string fileExtension;
        private VideoFormatGroup group;

        protected VideoFormat(string displayName, string filePart, string fileExtension, VideoFormatGroup group) {
            this.displayName = displayName;
            this.filePart = filePart;
            this.fileExtension = fileExtension;
            this.group = group;
        }
        public string DisplayName {
            get { return displayName; }
        }
        public string GroupName {
            get { return group.DisplayName; }
        }
        public VideoFormatGroup Group {
            get { return group; }
        }
        public int GroupOrder {
            get { return group.Order; }
        }
        public override string ToString() {
            return displayName;
        }
        public string OutputFileExtension {
            get {
                return string.Format(".{0}.{1}",
                    filePart, fileExtension);
            }
        }
        public abstract string GetArguments(string inputFileName, string outputFileName);
        public abstract VideoConverter MakeConverter(string fileName);
    }
}
