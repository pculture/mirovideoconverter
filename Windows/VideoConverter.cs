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
    class VideoConverter : IDisposable {
        private static Regex durationRegex = new Regex(@"^\s+Duration: (\d\d:\d\d:\d\d.\d\d)");
        private static Regex timeRegex = new Regex(@"time=([^\s]+)\u0020bitrate");
        private static Regex finishedRegex = new Regex(@"^video:");
        private static Regex unknownFormatRegex = new Regex(@"Unknown format$");

        internal event EventHandler<VideoConvertProgressArgs> ConvertProgress;
        internal event EventHandler<FFMPEGOutputArgs> FFMPEGOutput;
        internal event EventHandler<EventArgs> Finished;
        internal event EventHandler<EventArgs> UnknownFormat;

        private Process process;
        private ProcessStartInfo startInfo;
        private VideoFormat videoFormat;
        private long lengthMs = -1;
        private string outputFileName = null;

        public VideoConverter(string fileName, VideoFormat format) {
            string thisExeDir = Path.GetDirectoryName(
                System.Reflection.Assembly.GetExecutingAssembly().Location);
            this.videoFormat = format;
            string ffmpegArgs;
            if (format == VideoFormat.Theora)
                ffmpegArgs = string.Format(
                    "-i \"{0}\" -y -vcodec libtheora -b 640k -acodec libvorbis -ab 128k " +
                    "-ac 2 \"{1}\"",
                    fileName,
                    outputFileName = Path.ChangeExtension(fileName, ".theora.ogv"));
            else if (format == VideoFormat.G1)
                ffmpegArgs = string.Format(
                    "-i \"{0}\" -y -fpre \"{1}\" -aspect 3:2 -s 400x300 -r 23.976 " +
                    "-vcodec libx264 -b 480k -acodec aac -ab 96k -threads 0 " +
                    "\"{2}\"",
                    fileName, 
                    Path.Combine(thisExeDir, @"ffmpeg-bin\libx264hq.ffpreset"),
                    outputFileName = Path.ChangeExtension(fileName, ".g1.mp4"));
            else // PSP
                ffmpegArgs = string.Format(
                    "-i \"{0}\" -y -b 300k -s 320x240 -vcodec libxvid -ab 32k " +
                    "-ar 24000 -acodec aac \"{1}\"", fileName,
                    outputFileName = Path.ChangeExtension(fileName, ".psp.mp4"));
            this.startInfo = new ProcessStartInfo(
                Path.Combine(thisExeDir,
                @"ffmpeg-bin\ffmpeg.exe"), ffmpegArgs);
            this.startInfo.UseShellExecute = false;
            this.startInfo.CreateNoWindow = true;
            this.startInfo.RedirectStandardError = true;
            this.startInfo.RedirectStandardOutput = true;
        }
        public void Start() {
            if (process != null)
                throw new InvalidOperationException(
                    "VideoConverter is used once then disposed");
            process = new Process();
            process.StartInfo = this.startInfo;
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
                if (File.Exists(outputFileName))
                    File.Delete(outputFileName);
            }
            catch { 
                // do nothing
            }
        }
        public void Dispose() {
            if (this.process != null)
                this.process.Dispose();
        }
        public string OutputFileName { 
            get {
                return outputFileName;
            }
        }
        private void process_OutputDataReceived(object sender, DataReceivedEventArgs e) {
            // really just for entertainment, since ffmpeg 
            // doesn't seem to send anything to stdout.
            Debug.Print("OUTPUT");
            Debug.Print(e.Data);
        }
        private void process_ErrorDataReceived(object sender, DataReceivedEventArgs e) {
            Debug.Print("ERROR");
            Debug.Print(e.Data);
            string line = e.Data;
            if (line == null)
                return;
            if (FFMPEGOutput != null)
                FFMPEGOutput(this, new FFMPEGOutputArgs(line));
            if (lengthMs == -1 && durationRegex.IsMatch(line)) {
                Match m = durationRegex.Match(line);
                lengthMs = (long)TimeSpan.Parse(m.Groups[1].Value).TotalMilliseconds;
            }
            else if (timeRegex.IsMatch(line)) {
                if (ConvertProgress != null) {
                    Match m = timeRegex.Match(line);
                    string[] components = m.Groups[1].Value.Split(':', '.');
                    long ms = 0;
                    long[] factors = new long[] { 10, 100, 60, 60 };
                    long curFactor = 1;
                    for (int i = 0; i < components.Length; i++) {
                        curFactor *= factors[i];
                        ms += Int32.Parse(components[components.Length - 1 - i]) * curFactor;
                    }
                    ConvertProgress(this, new VideoConvertProgressArgs((int)(100 * ms / lengthMs)));
                }
            }
            else if (finishedRegex.IsMatch(line)) {
                if (Finished != null)
                    Finished(this, new EventArgs());
            }
            else if (unknownFormatRegex.IsMatch(line))
                if (UnknownFormat != null)
                    UnknownFormat(this, new EventArgs());
        }
    }
}
