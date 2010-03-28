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
using System.Text.RegularExpressions;
using SProcess = System.Diagnostics.Process;

namespace Mirosubs.Converter.Windows.Process {
    /// <summary>
    /// Encapsulates video conversion process.
    /// </summary>
    abstract class VideoConverter : IDisposable {
        internal event EventHandler<VideoConvertProgressArgs> ConvertProgress;
        internal event EventHandler<EventArgs> UnknownFormat;
        internal event EventHandler<ProcessOutputArgs> Output;
        internal event EventHandler<EventArgs> Finished;

        private SProcess process;

        public void Start() {
            if (process != null)
                throw new InvalidOperationException(
                    "VideoConverter is used once then disposed");
            IssueOutputEvent(string.Format("{0} {1}", ExeName, Args));
            ProcessStartInfo startInfo = new ProcessStartInfo(
                Path.Combine(ExecutableDir, ExeName),
                Args);
            startInfo.UseShellExecute = false;
            startInfo.CreateNoWindow = true;
            startInfo.RedirectStandardError = true;
            startInfo.RedirectStandardOutput = true;
            process = new SProcess();
            process.StartInfo = startInfo;
            process.ErrorDataReceived +=
                new DataReceivedEventHandler(
                    process_ErrorDataReceived);
            process.OutputDataReceived +=
                new DataReceivedEventHandler(
                    process_OutputDataReceived);
            process.Start();
            process.BeginOutputReadLine();
            process.BeginErrorReadLine();
        }


        public void Cancel() {
            try {
                if (process != null)
                    process.Kill();
                if (File.Exists(OutputFileName))
                    File.Delete(OutputFileName);
            }
            catch { 
                // do nothing
            }
        }
        protected abstract string ExeName { get; }
        protected abstract string Args { get; }
        protected abstract void process_OutputDataReceived(object sender, DataReceivedEventArgs e);
        protected abstract void process_ErrorDataReceived(object sender, DataReceivedEventArgs e);
        public abstract string OutputFileName { get; }
        protected void IssueConvertProgressEvent(int progress) {
            if (ConvertProgress != null)
                ConvertProgress(this, new VideoConvertProgressArgs(progress));
        }
        protected void IssueUnknownFormatEvent() {
            if (UnknownFormat != null) {
                UnknownFormat(this, new EventArgs());
            }
        }
        public void Dispose() {
            if (this.process != null)
                this.process.Dispose();
        }
        protected void IssueFinishedEvent() {
            if (Finished != null)
                Finished(this, new EventArgs());
        }
        protected void IssueOutputEvent(string line) {
            if (Output != null)
                Output(this, new ProcessOutputArgs(line));
        }
        protected string ExecutableDir {
            get {
                return Path.GetDirectoryName(
                    System.Reflection.Assembly.GetExecutingAssembly().Location);
            }
        }
    }
}
