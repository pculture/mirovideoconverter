using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Mirosubs.Converter.Windows.VideoFormats;

namespace Mirosubs.Converter.Windows.Process {
    class VideoParameters {
        public float? AudioBitrate { get; set; }
        public float? VideoBitrate { get; set; }
        public int? Width { get; set; }
        public int? Height { get; set; }
        public VideoSize VideoSize {
            get {
                if (Width.HasValue && Height.HasValue)
                    return new VideoSize() {
                        Width = Width.Value,
                        Height = Height.Value
                    };
                else
                    return null;
            }
        }
    }
}
