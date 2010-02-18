using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Mirosubs.Converter.Windows {
    class VideoConvertProgressArgs : EventArgs {
        public readonly int Progress;
        public VideoConvertProgressArgs(int progress) {
            this.Progress = progress;
        }
    }
}
