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
using System.IO;
using System.Diagnostics;
using System.Text.RegularExpressions;
using Mirosubs.Converter.Windows.ConversionFormats;
using System.Globalization;

namespace Mirosubs.Converter.Windows.Process {
    class F2TVideoConverterProcess : VideoConverter {
        private static Regex updateRegex = new Regex(
            @"^\{\""duration\""\s*:\s*([\d\.]+),\s*\""position\""\s*:\s*([\d\.]+)");
        private static Regex finishedRegex = new Regex(
            @"\{\""result\""\s*:\s*\""ok\""\}");
        private static Regex errorRegex = new Regex(
            @"^\s*\""error\""\s*:\s*\""([^\""]+)");

        private string fileName;
        private string outputFileName;
        private string args;
        internal F2TVideoConverterProcess(string fileName, bool useSimpleArguments) {
            this.fileName = fileName;
            this.outputFileName =
                Path.ChangeExtension(fileName, 
                TheoraVideoFormat.Theora.OutputFileExtension);
            if (useSimpleArguments)
                args = TheoraVideoFormat.Theora.GetSimpleArguments(
                    fileName, outputFileName);
            else
                args = TheoraVideoFormat.Theora.GetArguments(
                    fileName, outputFileName);
        }
        public override string OutputFileName {
            get { return this.outputFileName; }
        }
        protected override string ExeName {
            get {
                return @"ffmpeg-bin\ffmpeg2theora.exe";
            }
        }
        protected override string Args {
            get {
                return args;
            }
        }
        protected override void process_OutputDataReceived(object sender, System.Diagnostics.DataReceivedEventArgs e) {
            Debug.Print("Output");
            Debug.Print(e.Data);
            string line = e.Data;
            if (line == null)
                return;
            IssueOutputEvent(line);
            if (updateRegex.IsMatch(line)) {
                Match m = updateRegex.Match(line);
                float position;
                float duration;
                try
                {
                    position = float.Parse(m.Groups[2].Value,
                    NumberFormatInfo.InvariantInfo);
                } catch (OverflowException) {
                    position = 0.0f;
                } finally {
                    duration = float.Parse(m.Groups[1].Value,
                    NumberFormatInfo.InvariantInfo);
                }            
                int progress = (int)(100 * position / duration);
                if (progress < 0)
                    progress = 999;
                IssueConvertProgressEvent(progress);
            }
            else if (finishedRegex.IsMatch(line))
                IssueFinishedEvent();
            else if (errorRegex.IsMatch(line)) {
                IssueUnknownFormatEvent();
            }
        }

        protected override void process_ErrorDataReceived(object sender, System.Diagnostics.DataReceivedEventArgs e) {
            Debug.Print("Error");
            Debug.Print(e.Data);
            IssueOutputEvent(e.Data);
        }
    }
}
