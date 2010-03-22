using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Mirosubs.Converter.Windows.VideoFormats {
    class VideoSize : IComparable {
        public int Width { get; set; }
        public int Height { get; set; }

        public int CompareTo(object obj) {
            VideoSize other = (VideoSize)obj;
            if (Width > other.Width ||
                Height > other.Height)
                return 1;
            else if (Width < other.Width &&
                Height < other.Height)
                return -1;
            else
                return 0;
        }
    }
}
