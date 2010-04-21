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
    abstract class ConversionFormat {
        public static readonly ConversionFormat[] All = new ConversionFormat[] { 
            AndroidVideoFormat.G1, 
            PSPVideoFormat.PSP, 
            TheoraVideoFormat.Theora, 
            MP3Format.MP3,
            MP4Format.MP4,
            AndroidVideoFormat.NexusOne, 
            AndroidVideoFormat.MagicMyTouch, 
            AndroidVideoFormat.Droid, 
            AndroidVideoFormat.ErisDesire,
            AndroidVideoFormat.Hero, 
            AndroidVideoFormat.CliqDEXT, 
            AndroidVideoFormat.BeholdII, 
            AppleVideoFormat.iPhone, 
            AppleVideoFormat.iPad,
            AppleVideoFormat.iPodTouch, 
            AppleVideoFormat.iPodNano, 
            AppleVideoFormat.iPodClassic
        };

        public static ConversionFormat FindByDisplayName(string displayName) {
            return All.FirstOrDefault(cf => cf.DisplayName == displayName);
        }

        private string displayName;
        private string filePart;
        private string fileExtension;
        private VideoFormatGroup group;

        protected ConversionFormat(string displayName, string filePart, string fileExtension, VideoFormatGroup group) {
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
        /// <summary>
        /// Obtain size argument for FFMPEG, in -s WIDTHxHEIGHT format.
        /// If either dimension of the input video is larger than target 
        /// size, this will resize it to fit into the target size. 
        /// Otherwise will return a blank string.
        /// </summary>
        /// <param name="inputFileName"></param>
        /// <param name="targetSize"></param>
        /// <returns></returns>
        protected string GetSizeArgument(string inputFileName, 
                                         VideoSize targetSize) {
            VideoParameters parms =
                VideoParameterOracle.GetParameters(inputFileName);
            VideoSize size = parms == null ? null : parms.VideoSize;
            string sizeArg = "";
            if (size != null && size.CompareTo(targetSize) > 0) {
                float widthRatio = (float)size.Width / targetSize.Width;
                float heightRatio = (float)size.Height / targetSize.Height;
                float ratio = Math.Max(widthRatio, heightRatio);
                sizeArg = string.Format("-s {0}x{1}",
                    (int)(size.Width / ratio),
                    (int)(size.Height / ratio));
            }
            return sizeArg;
        }
        public string OutputFileExtension {
            get {
                return string.Format(".{0}.{1}",
                    filePart, fileExtension);
            }
        }
        public virtual int Order {
            get { return 0; }
        }
        public abstract string GetArguments(string inputFileName, string outputFileName);
        public abstract VideoConverter MakeConverter(string fileName);
    }
}
