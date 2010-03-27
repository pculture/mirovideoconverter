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
using System.Diagnostics;
using System.IO;
using SProcess = System.Diagnostics.Process;
using System.Text.RegularExpressions;

namespace Mirosubs.Converter.Windows.Process {
    class VideoParameterOracle {
        private readonly static Regex WidthRegex = new Regex(@"width\"": (\d+)");
        private readonly static Regex HeightRegex = new Regex(@"height\"": (\d+)");
        private readonly static Regex VideoBitrateRegex = new Regex(
            @"video\"": \[\{[^\}]+bitrate\"": ([\d\.]+)", 
            RegexOptions.Multiline);
        private readonly static Regex AudioBitrateRegex = new Regex(
            @"audio\"": \[\{[^\}]+bitrate\"": ([\d\.]+)", 
            RegexOptions.Multiline);

        public static VideoParameters GetParameters(string videoFileName) {
            try {
                string exeName = Path.Combine(Path.GetDirectoryName(
                        System.Reflection.Assembly.GetExecutingAssembly().Location),
                        @"ffmpeg-bin\ffmpeg2theora.exe");
                string args = string.Format("--info \"{0}\"", videoFileName);
                ProcessStartInfo startInfo = new ProcessStartInfo(
                    exeName, args);
                startInfo.UseShellExecute = false;
                startInfo.CreateNoWindow = true;
                startInfo.RedirectStandardOutput = true;
                startInfo.RedirectStandardError = true;
                SProcess process = new SProcess();
                process.StartInfo = startInfo;
                process.Start();
                string output = process.StandardOutput.ReadToEnd();
                process.WaitForExit();
                return ParamsFromOutput(output);
            }
            catch (Exception) {
                return null;
            }
        }

        private static VideoParameters ParamsFromOutput(string output) {
            int? width = null;
            if (WidthRegex.IsMatch(output))
                width = int.Parse(WidthRegex.Match(output).Groups[1].Value);
            int? height = null;
            if (HeightRegex.IsMatch(output))
                height = int.Parse(HeightRegex.Match(output).Groups[1].Value);
            float? audioBitrate = null;
            if (AudioBitrateRegex.IsMatch(output))
                audioBitrate = float.Parse(AudioBitrateRegex.Match(output).Groups[1].Value);
            float? videoBitrate = null;
            if (VideoBitrateRegex.IsMatch(output))
                videoBitrate = float.Parse(VideoBitrateRegex.Match(output).Groups[1].Value);
            return new VideoParameters() {
                Width = width,
                Height = height,
                AudioBitrate = audioBitrate,
                VideoBitrate = videoBitrate
            };
        }
    }
}
