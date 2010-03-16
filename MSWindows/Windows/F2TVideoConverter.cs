using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Diagnostics;
using System.Text.RegularExpressions;
using Mirosubs.Converter.Windows.VideoFormats;

namespace Mirosubs.Converter.Windows {
    class F2TVideoConverter : VideoConverter {
        private static Regex updateRegex = new Regex(
            @"^\{\""duration\""\s*:\s*([\d\.]+),\s*\""position\""\s*:\s*([\d\.]+)");
        private static Regex finishedRegex = new Regex(
            @"\{\""result\""\s*:\s*\""ok\""\}");
        private static Regex errorRegex = new Regex(
            @"^\s*\""error\""\s*:\s*\""([^\""]+)");

        private string fileName;
        private string outputFileName;
        private string args;
        internal F2TVideoConverter(string fileName) {
            this.fileName = fileName;
            this.outputFileName =
                Path.ChangeExtension(fileName, 
                TheoraVideoFormat.Theora.OutputFileExtension);
            args = TheoraVideoFormat.Theora.GetArguments(fileName, outputFileName);
        }
        public override string OutputFileName {
            get { return this.fileName; }
        }
        protected override string ConversionExeName {
            get {
                return @"ffmpeg-bin\ffmpeg2theora.exe";
            }
        }
        protected override string ConversionArgs {
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
            IssueConvertOutputEvent(line);
            if (updateRegex.IsMatch(line)) {
                Match m = updateRegex.Match(line);
                float duration = float.Parse(m.Groups[1].Value);
                float position = float.Parse(m.Groups[2].Value);
                IssueConvertProgressEvent((int)(100 * position / duration));
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
        }
    }
}
