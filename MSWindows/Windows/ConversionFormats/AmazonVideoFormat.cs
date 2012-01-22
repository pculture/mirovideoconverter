﻿//  MiroVideoConverter -- a super simple way to convert almost any video to MP4, 
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

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Mirosubs.Converter.Windows.Process;

namespace Mirosubs.Converter.Windows.ConversionFormats
{
    class AmazonVideoFormat : ConversionFormat
    {
        public readonly static ConversionFormat KindleFire =
            new AmazonVideoFormat("Kindle Fire", "kindlefire");

        private AmazonVideoFormat(string displayName, string filePart)
            : base(displayName, filePart, "mp4", VideoFormatGroup.Other)
        {
        }

        public override string GetArguments(string inputFileName, string outputFileName)
        {
            return string.Format(
                "-i \"{0}\" -acodec aac -ab 96k -vcodec libx264 -vpre slow -f mp4 -crf 22" +
                " -s 1024x600 -strict experimental \"{1}\"", inputFileName, outputFileName);
        }
        public override IVideoConverter MakeConverter(string fileName)
        {
            return new FFMPEGVideoConverter(fileName, this);
        }
    }
}
