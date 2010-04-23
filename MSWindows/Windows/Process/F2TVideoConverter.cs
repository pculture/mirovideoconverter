using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

namespace Mirosubs.Converter.Windows.Process {
    class F2TVideoConverter : IVideoConverter {
        private static Regex couldNotFindModeRegex = new Regex(
            @"Vorbis encoder could not set up a mode");


        public event EventHandler<VideoConvertProgressArgs> ConvertProgress;
        public event EventHandler<EventArgs> UnknownFormat;
        public event EventHandler<ProcessOutputArgs> Output;
        public event EventHandler<EventArgs> Finished;

        private string fileName;
        private bool couldNotFindMode = false;
        private F2TVideoConverterProcess process;

        public F2TVideoConverter(string fileName) {
            this.fileName = fileName;
        }

        public void Start() {
            process = new F2TVideoConverterProcess(this.fileName, false);
            AddEventHandlersToProcess(process);
            process.Start();
        }

        private void AddEventHandlersToProcess(F2TVideoConverterProcess process) {
            process.ConvertProgress += new EventHandler<VideoConvertProgressArgs>(process_ConvertProgress);
            process.Finished += new EventHandler<EventArgs>(process_Finished);
            process.Output += new EventHandler<ProcessOutputArgs>(process_Output);
            process.UnknownFormat += new EventHandler<EventArgs>(process_UnknownFormat);
        }

        void process_UnknownFormat(object sender, EventArgs e) {
            if (UnknownFormat != null)
                UnknownFormat(this, e);
        }

        void process_Output(object sender, ProcessOutputArgs e) {
            if (e.OutputLine == null)
                return;
            if (Output != null)
                Output(this, e);
            if (couldNotFindModeRegex.IsMatch(e.OutputLine) && !couldNotFindMode) {
                couldNotFindMode = true;
                if (Output != null)
                    Output(this, new ProcessOutputArgs(
                        "Could not find mode, so switching to simplified arguments."));
                process.Cancel();
                process.Dispose();
                process = new F2TVideoConverterProcess(this.fileName, true);
                AddEventHandlersToProcess(process);
                process.Start();
            }
        }

        void process_Finished(object sender, EventArgs e) {
            if (Finished != null)
                Finished(this, e);
        }

        void process_ConvertProgress(object sender, VideoConvertProgressArgs e) {
            if (ConvertProgress != null)
                ConvertProgress(this, e);
        }

        public void Cancel() {
            process.Cancel();
        }

        public string OutputFileName {
            get { return process.OutputFileName; }
        }

        public void Dispose() {
            process.Dispose();
        }
    }
}
