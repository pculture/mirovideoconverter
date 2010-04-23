using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Mirosubs.Converter.Windows.Process {
    interface IVideoConverter : IDisposable {
        event EventHandler<VideoConvertProgressArgs> ConvertProgress;
        event EventHandler<EventArgs> UnknownFormat;
        event EventHandler<ProcessOutputArgs> Output;
        event EventHandler<EventArgs> Finished;

        void Start();
        void Cancel();
        string OutputFileName { get; }
    }
}
