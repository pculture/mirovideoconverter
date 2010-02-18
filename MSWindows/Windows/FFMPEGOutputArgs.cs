using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Mirosubs.Converter.Windows {
    class FFMPEGOutputArgs : EventArgs {
        public readonly String OutputLine;
        public FFMPEGOutputArgs(string outputLine) {
            this.OutputLine = outputLine;
        }
    }
}
