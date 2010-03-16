using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Mirosubs.Converter.Windows.Process;

namespace Mirosubs.Converter.Windows.VideoFormats {
    class AndroidVideoFormat : VideoFormat {
        private const string DEFAULT_ASPECT = "3:2";
        private const string DEFAULT_DIM = "480x320";
        private const string NEXUS_ASPECT = "1.6666";
        private const string NEXUS_DIM = "800x480";
        private const string DROID_ASPECT = "1.7666";
        private const string DROID_DIM = "848x480";

        public readonly static VideoFormat G1 =
            new AndroidVideoFormat("G1", "g1");
        public readonly static VideoFormat NexusOne =
            new AndroidVideoFormat("Nexus One", "nexusone",
                NEXUS_ASPECT, NEXUS_DIM);
        public readonly static VideoFormat MagicMyTouch =
            new AndroidVideoFormat("Magic / myTouch", "magic");
        public readonly static VideoFormat Droid =
            new AndroidVideoFormat("Droid", "droid",
                DROID_ASPECT, DROID_DIM);
        public readonly static VideoFormat ErisDesire =
            new AndroidVideoFormat("Eris / Desire", "eris");
        public readonly static VideoFormat Hero =
            new AndroidVideoFormat("Hero", "hero");
        public readonly static VideoFormat CliqDEXT =
            new AndroidVideoFormat("Cliq / DEXT", "cliq");
        public readonly static VideoFormat BeholdII =
            new AndroidVideoFormat("Behold II", "behold");

        private string aspectRatio;
        private string dimensions;

        private AndroidVideoFormat(string displayName, string filePart)
            : this(displayName, filePart, DEFAULT_ASPECT, DEFAULT_DIM) {
        }

        private AndroidVideoFormat(string displayName, 
            string filePart, string aspectRatio, string dimensions) 
            : base(displayName, filePart, "mp4", VideoFormatGroup.Android) {
            this.aspectRatio = aspectRatio;
            this.dimensions = dimensions;
        }

        public override string GetArguments(string inputFileName, string outputFileName) {
            return string.Format(
                "-i \"{0}\" -y -f mp4 -vcodec libxvid -maxrate 1000k -b 700k " +
                "-qmin 3 -qmax 5 -bufsize 4096 -g 300 -aspect {1} -s {2} " +
                "-acodec aac -ab 96000 \"{3}\"",
                inputFileName, aspectRatio, dimensions, outputFileName);
        }

        public override VideoConverter MakeConverter(string fileName) {
            return new FFMPEGVideoConverter(fileName, this);
        }
    }
}
