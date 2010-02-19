using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Mirosubs.Converter.Windows {
    class ConversionOutputArgs : EventArgs {
        public readonly String OutputLine;
        public ConversionOutputArgs(string outputLine) {
            this.OutputLine = outputLine;
        }
    }
}
