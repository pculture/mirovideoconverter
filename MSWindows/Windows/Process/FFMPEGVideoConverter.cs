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
using System.Text.RegularExpressions;
using System.Diagnostics;
using System.IO;
using Mirosubs.Converter.Windows.ConversionFormats;

namespace Mirosubs.Converter.Windows.Process {
    class FFMPEGVideoConverter : VideoConverter {
        private readonly string args;

        private static Regex durationRegex = new Regex(@"^\s+Duration: (\d\d:\d\d:\d\d.\d\d)");
        private static Regex timeRegex = new Regex(@"time=([^\s]+)\u0020bitrate");
        private static Regex finishedRegex = new Regex(@"^video:");
        private static Regex unknownFormatRegex = new Regex(
            @"Unknown format$");
        private static Regex couldNotWriteHeader = new Regex(
            @"Could not write header.*incorrect codec parameters");

        private long lengthMs = -1;
        private string outputFileName;

        internal FFMPEGVideoConverter(string fileName, ConversionFormat format) {
            args = format.GetArguments(fileName,
                outputFileName = Path.ChangeExtension(fileName,
                    format.OutputFileExtension));
        }
        protected override string ExeName {
            get { return @"ffmpeg-bin\ffmpeg.exe"; }
        }
        protected override string Args {
            get { return args; }
        }
        public override string OutputFileName {
            get { return outputFileName; }
        }
        protected override void process_OutputDataReceived(object sender, System.Diagnostics.DataReceivedEventArgs e) {
            // really just for entertainment, since ffmpeg 
            // doesn't seem to send anything to stdout.
            Debug.Print("OUTPUT");
            Debug.Print(e.Data);
        }
        protected override void process_ErrorDataReceived(object sender, System.Diagnostics.DataReceivedEventArgs e) {
            Debug.Print("ERROR");
            Debug.Print(e.Data);
            string line = e.Data;
            if (line == null)
                return;
            IssueOutputEvent(line);
            if (lengthMs == -1 && durationRegex.IsMatch(line)) {
                Match m = durationRegex.Match(line);
                lengthMs = (long)TimeSpan.Parse(m.Groups[1].Value).TotalMilliseconds;
            }
            else if (timeRegex.IsMatch(line)) {
                Match m = timeRegex.Match(line);
                string[] components = m.Groups[1].Value.Split(':', '.');
                long ms = 0;
                long[] factors = new long[] { 10, 100, 60, 60 };
                long curFactor = 1;
                for (int i = 0; i < components.Length; i++) {
                    curFactor *= factors[i];
                    try {
                        ms += Int32.Parse(components[components.Length - 1 - i]) * curFactor;
                    }
                    catch (Exception) {
                        // FFMPEG sometimes reports time as 10000000000.00
                    }
                }
                IssueConvertProgressEvent((int)(100 * ms / lengthMs));
            }
            else if (finishedRegex.IsMatch(line))
                IssueFinishedEvent();
            else if (unknownFormatRegex.IsMatch(line))
                IssueUnknownFormatEvent();
            else if (couldNotWriteHeader.IsMatch(line))
                IssueUnknownFormatEvent();
        }
    }
}
