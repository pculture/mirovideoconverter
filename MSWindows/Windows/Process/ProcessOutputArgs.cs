using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Mirosubs.Converter.Windows.Process {
    class ProcessOutputArgs : EventArgs {
        public readonly String OutputLine;
        public ProcessOutputArgs(string outputLine) {
            this.OutputLine = outputLine;
        }
    }
}
