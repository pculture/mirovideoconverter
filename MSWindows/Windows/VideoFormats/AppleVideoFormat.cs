using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Mirosubs.Converter.Windows.Process;

namespace Mirosubs.Converter.Windows.VideoFormats {
    class AppleVideoFormat : VideoFormat {
        public readonly static VideoFormat iPhone =
            new AppleVideoFormat("iPhone", "iphone");
        public readonly static VideoFormat iPodTouch =
            new AppleVideoFormat("iPod Touch", "ipodtouch");
        public readonly static VideoFormat iPodNano =
            new AppleVideoFormat("iPod Nano", "ipodnano");
        public readonly static VideoFormat iPodClassic =
            new AppleVideoFormat("iPod Classic", "ipodclassic");

        private AppleVideoFormat(string displayName, string filePart)
            : base(displayName, filePart, "mp4", VideoFormatGroup.Apple) {
        }
        public override string GetArguments(string inputFileName, string outputFileName) {
            return string.Format(
                "-i \"{0}\"  -acodec aac -ab 96000 -vcodec mpeg4 -b 1200kb " +
                "-mbd 2 -cmp 2 -subcmp 2 -s 480x320 -r 20 \"{1}\"",
                inputFileName, outputFileName);
        }
        public override VideoConverter MakeConverter(string fileName) {
            return new FFMPEGVideoConverter(fileName, this);
        }
    }
}
