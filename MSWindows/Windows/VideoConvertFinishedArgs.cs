using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Mirosubs.Converter.Windows {
    class VideoConvertFinishedArgs : EventArgs {
        public readonly string outputFileName;
        public VideoConvertFinishedArgs(string fileName) {
            this.outputFileName = fileName;
        }
    }
}
