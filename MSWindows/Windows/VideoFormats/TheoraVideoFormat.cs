using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Mirosubs.Converter.Windows.Process;
using System.IO;

namespace Mirosubs.Converter.Windows.VideoFormats {
    class TheoraVideoFormat : VideoFormat {
        public readonly static VideoFormat Theora =
            new TheoraVideoFormat("Theora", "theora");
        private TheoraVideoFormat(string displayName, string filePart)
            : base(displayName, filePart, "ogv", VideoFormatGroup.Formats) { 
        }
        public override string GetArguments(string inputFileName, string outputFileName) {
            VideoParameters parms = null;
            try {
                parms = VideoParameterOracle.GetParameters(inputFileName);
            }
            catch (Exception) { }
            if (parms == null)
                return string.Format(
                    "\"{0}\" -o \"{1}\" --videoquality 8 --audioquality 6 --frontend",
                    inputFileName, outputFileName);
            else {
                StringBuilder paramsBuilder = new StringBuilder();
                StringWriter paramsWriter = new StringWriter(paramsBuilder);
                if (parms.Height.HasValue && parms.Width.HasValue)
                    paramsWriter.Write("-x {0} -y {1} ", 
                        parms.Width, parms.Height);
                if (parms.VideoBitrate.HasValue && parms.AudioBitrate.HasValue)
                    paramsWriter.Write("-V {0} -A {1}", 
                        parms.VideoBitrate, parms.AudioBitrate);
                else
                    paramsWriter.Write("--videoquality 8 --audioquality 6");
                paramsWriter.Close();
                return string.Format(
                    "\"{0}\" -o \"{1}\" {2} --frontend",
                        inputFileName, outputFileName, paramsBuilder.ToString());
            }
        }
        public override VideoConverter MakeConverter(string fileName) {
            return new F2TVideoConverter(fileName);
        }
    }
}
