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
using System.IO;

namespace Mirosubs.Converter.Windows.VideoFormats {
    class TheoraVideoFormat : VideoFormat {
        public readonly static VideoFormat Theora =
            new TheoraVideoFormat("Theora", "theora");
        private TheoraVideoFormat(string displayName, string filePart)
            : base(displayName, filePart, "ogv", VideoFormatGroup.Formats) { 
        }
        public override string GetArguments(string inputFileName, string outputFileName) {
            VideoParameters parms = 
                VideoParameterOracle.GetParameters(inputFileName);
            if (parms == null)
                return string.Format(
                    "\"{0}\" -o \"{1}\" --videoquality 8 --audioquality 6 --frontend",
                    inputFileName, outputFileName);
            else {
                StringBuilder paramsBuilder = new StringBuilder();
                StringWriter paramsWriter = new StringWriter(paramsBuilder);
                if (parms.Height.HasValue && parms.Width.HasValue)
                    paramsWriter.Write("-x {0} -y {1} ", 
                        parms.Width, parms.Height);
                if (parms.VideoBitrate.HasValue && parms.AudioBitrate.HasValue)
                    paramsWriter.Write("-V {0} -A {1} --two-pass ", 
                        parms.VideoBitrate, parms.AudioBitrate);
                else
                    paramsWriter.Write("--videoquality 8 --audioquality 6 ");
                paramsWriter.Close();
                return string.Format(
                    "\"{0}\" -o \"{1}\" {2} --frontend",
                        inputFileName, outputFileName, paramsBuilder.ToString());
            }
        }
        public override VideoConverter MakeConverter(string fileName) {
            return new F2TVideoConverter(fileName);
        }
    }
}
