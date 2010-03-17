using System;
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
