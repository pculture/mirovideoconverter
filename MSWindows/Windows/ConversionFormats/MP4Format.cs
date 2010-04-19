using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Mirosubs.Converter.Windows.Process;

namespace Mirosubs.Converter.Windows.ConversionFormats {
    class MP4Format : ConversionFormat {
        public readonly static ConversionFormat MP4 = new MP4Format();

        private MP4Format()
            : base("MP4 Video", "mp4video", "mp4", VideoFormatGroup.Formats) { 
        }
        public override string GetArguments(string inputFileName, string outputFileName) {
            return string.Format("-i \"{0}\" -f mp4 -y -vcodec mpeg4 -sameq -r 20 \"{1}\"",
                inputFileName, outputFileName);
        }
        public override VideoConverter MakeConverter(string fileName) {
            return new FFMPEGVideoConverter(fileName, this);
        }
        public override int Order {
            get {
                return 1;
            }
        }
    }
}
