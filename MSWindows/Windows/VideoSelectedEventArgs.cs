using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Mirosubs.Converter.Windows.VideoFormats;

namespace Mirosubs.Converter.Windows {
    class VideoSelectedEventArgs : EventArgs {
        public readonly string FileName;
        public readonly VideoFormat Format;

        public VideoSelectedEventArgs(string fileName, VideoFormat format) {
            this.FileName = fileName;
            this.Format = format;
        }
    }
}
