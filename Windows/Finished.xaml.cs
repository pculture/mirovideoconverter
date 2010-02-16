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
using IOPath = System.IO.Path;

namespace Mirosubs.Converter.Windows {
    /// <summary>
    /// Interaction logic for Finished.xaml
    /// </summary>
    public partial class Finished : UserControl {
        internal event EventHandler<VideoSelectedEventArgs> FileSelected;

        private string outputFileName;

        public Finished(string outputFileName) {
            InitializeComponent();
            this.outputFileName = outputFileName;
            labelFinished.Content = string.Format(
                "Finished converting {0}!",
                IOPath.GetFileName(outputFileName));
            this.fileSelect.FileSelected += new EventHandler<VideoSelectedEventArgs>(VideoFileSelected);
        }

        private void VideoFileSelected(object sender, VideoSelectedEventArgs eventArgs) {
            if (FileSelected != null)
                FileSelected(this, eventArgs);
        }
        private void ShowFileClicked(object sender, RoutedEventArgs e) {
            System.Diagnostics.Process.Start(IOPath.GetDirectoryName(outputFileName));
        }
    }
}
