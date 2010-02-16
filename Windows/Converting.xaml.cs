using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.Diagnostics;
using IOPath = System.IO.Path;
using System.Threading;

namespace Mirosubs.Converter.Windows {
    /// <summary>
    /// Interaction logic for Converting.xaml
    /// </summary>
    public partial class Converting : UserControl {
        internal event EventHandler<EventArgs> Cancelled;
        internal event EventHandler<VideoConvertFinishedArgs> Finished;

        private VideoConverter converter;
        internal Converting(string fileName, VideoFormat format) {
            InitializeComponent();
            titleLabel.Content = string.Format("Converting {0}", 
                IOPath.GetFileName(fileName));
            progressLabel.Content = "Starting...";
            converter = new VideoConverter(fileName, format);
            converter.ConvertProgress += 
                new EventHandler<VideoConvertProgressArgs>(converter_ConvertProgress);
            converter.Finished += new EventHandler<EventArgs>(converter_Finished);
            converter.Start();
        }
        private void converter_Finished(object sender, EventArgs e) {
            if (this.Dispatcher.CheckAccess()) {
                if (Finished != null)
                    Finished(this, new VideoConvertFinishedArgs(
                        this.converter.OutputFileName));
            }
            else
                this.Dispatcher.Invoke((Action)(() => this.converter_Finished(sender, e)));
        }
        private void converter_ConvertProgress(object sender, VideoConvertProgressArgs e) {
            if (this.Dispatcher.CheckAccess()) {
                progressLabel.Content = string.Format("{0}% done", e.Progress);
                progressBar.Value = e.Progress;
            }
            else
                this.Dispatcher.Invoke((Action)(() => this.converter_ConvertProgress(sender, e)));
        }
        private void UserControl_Unloaded(object sender, RoutedEventArgs e) {
            converter.Dispose();
        }
        private void CancelClicked(object sender, RoutedEventArgs e) {
            converter.Cancel();
            if (Cancelled != null)
                Cancelled(this, new EventArgs());
        }
    }
}
