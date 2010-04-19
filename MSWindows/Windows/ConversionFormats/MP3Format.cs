using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Mirosubs.Converter.Windows.Process;

namespace Mirosubs.Converter.Windows.ConversionFormats {
    class MP3Format : ConversionFormat {
        public readonly static ConversionFormat MP3 =
            new MP3Format();

        private MP3Format()
            : base("MP3 (Audio Only)", "audioonly", "mp3", VideoFormatGroup.Formats) { 
        }
        public override string GetArguments(string inputFileName, string outputFileName) {
            return string.Format("-i \"{0}\" -f mp3 -y -acodec ac3 \"{1}\"",
                inputFileName, outputFileName);
        }
        public override VideoConverter MakeConverter(string fileName) {
            return new FFMPEGVideoConverter(fileName, this);
        }
        public override int Order {
            get {
                return 2;
            }
        }
    }
}
