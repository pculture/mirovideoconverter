using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Diagnostics;

namespace Mirosubs.Converter.Windows {
    class F2TVideoConverter : VideoConverter {
        private string fileName;
        private string outputFileName;
        private string args;
        internal F2TVideoConverter(string fileName) {
            this.fileName = fileName;
            this.outputFileName =
                Path.ChangeExtension(fileName, ".theora.ogv");
            args = string.Format(
                "\"{0}\" -o \"{1}\" --videoquality 8 --audioquality 6 --frontend",
                fileName, outputFileName);
        }
        public override string OutputFileName {
            get { return this.fileName; }
        }
        protected override string ConversionExeName {
            get {
                return @"ffmpeg-bin\ffmpeg2theora-0.26.exe";
            }
        }
        protected override string ConversionArgs {
            get {
                return args;
            }
        }
        protected override void process_OutputDataReceived(object sender, System.Diagnostics.DataReceivedEventArgs e) {
            Debug.Print(e.Data);
        }

        protected override void process_ErrorDataReceived(object sender, System.Diagnostics.DataReceivedEventArgs e) {
            Debug.Print(e.Data);
        }
    }
}
