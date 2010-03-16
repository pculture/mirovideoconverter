using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Mirosubs.Converter.Windows.VideoFormats {
    class TheoraVideoFormat : VideoFormat {
        public readonly static VideoFormat Theora =
            new TheoraVideoFormat("Theora", "theora");
        private TheoraVideoFormat(string displayName, string filePart)
            : base(displayName, filePart, "ogv", VideoFormatGroup.Formats) { 
        }
        public override string GetArguments(string inputFileName, string outputFileName) {
            return string.Format(
                "\"{0}\" -o \"{1}\" --videoquality 8 --audioquality 6 --frontend",
                inputFileName, outputFileName);
        }
        public override VideoConverter MakeConverter(string fileName) {
            return new F2TVideoConverter(fileName);
        }
    }
}
