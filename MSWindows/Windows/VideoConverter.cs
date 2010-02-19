using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Diagnostics;
using System.IO;
using System.Text.RegularExpressions;

namespace Mirosubs.Converter.Windows {
    /// <summary>
    /// Encapsulates video conversion process.
    /// </summary>
    abstract class VideoConverter : IDisposable {
        internal event EventHandler<VideoConvertProgressArgs> ConvertProgress;
        internal event EventHandler<ConversionOutputArgs> ConvertOutput;
        internal event EventHandler<EventArgs> Finished;
        internal event EventHandler<EventArgs> UnknownFormat;

        private Process process;

        public void Start() {
            if (process != null)
                throw new InvalidOperationException(
                    "VideoConverter is used once then disposed");
            ProcessStartInfo startInfo = new ProcessStartInfo(
                Path.Combine(ExecutableDir, ConversionExeName), 
                ConversionArgs);
            startInfo.UseShellExecute = false;
            startInfo.CreateNoWindow = true;
            startInfo.RedirectStandardError = true;
            startInfo.RedirectStandardOutput = true;
            process = new Process();
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
        public void Dispose() {
            if (this.process != null)
                this.process.Dispose();
        }
        public abstract string OutputFileName { get; }
        protected abstract string ConversionExeName { get; }
        protected abstract string ConversionArgs { get; }
        protected abstract void process_OutputDataReceived(object sender, DataReceivedEventArgs e);
        protected abstract void process_ErrorDataReceived(object sender, DataReceivedEventArgs e);
        protected string ExecutableDir {
            get {
                return Path.GetDirectoryName(
                    System.Reflection.Assembly.GetExecutingAssembly().Location);
            }
        }
        protected void IssueConvertProgressEvent(int progress) {
            if (ConvertProgress != null)
                ConvertProgress(this, new VideoConvertProgressArgs(progress));
        }
        protected void IssueConvertOutputEvent(string line) {
            if (ConvertOutput != null)
                ConvertOutput(this, new ConversionOutputArgs(line));
        }
        protected void IssueFinishedEvent() {
            if (Finished != null)
                Finished(this, new EventArgs());
        }
        protected void IssueUnknownFormatEvent() {
            if (UnknownFormat != null) {
                UnknownFormat(this, new EventArgs());
            }
        }
    }
}
