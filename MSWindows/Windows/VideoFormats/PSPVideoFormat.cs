using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Mirosubs.Converter.Windows.Process;

namespace Mirosubs.Converter.Windows.VideoFormats {
    class PSPVideoFormat  : VideoFormat {
        public readonly static VideoFormat PSP =
            new PSPVideoFormat("PSP", "psp");

        private PSPVideoFormat(string displayName, string filePart)
            : base(displayName, filePart, "mp4", VideoFormatGroup.Other) { 
        }

        public override string GetArguments(string inputFileName, string outputFileName) {
            return string.Format(
                "-i \"{0}\" -y -aspect 4:3 -s 480x272 -vcodec libxvid -sameq " +
                "-ab 32000 -ar 24000 -acodec aac \"{1}\"", inputFileName,
                outputFileName);
        }
        public override VideoConverter MakeConverter(string fileName) {
            return new FFMPEGVideoConverter(fileName, this);
        }
    }
}
