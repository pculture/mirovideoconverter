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

namespace Mirosubs.Converter.Windows {
    /// <summary>
    /// Interaction logic for Window1.xaml
    /// </summary>
    public partial class MainWindow : Window {
        private Converting convertingView = null;

        public MainWindow() {
            InitializeComponent();
            fileSelect.FileSelected += new EventHandler<VideoSelectedEventArgs>(VideoFileSelected);
        }

        private void VideoFileSelected(object sender, VideoSelectedEventArgs e) {
            this.mainGrid.Children.Remove(fileSelect);
            fileSelect.FileSelected -= new EventHandler<VideoSelectedEventArgs>(VideoFileSelected);
            Converting convertingView = new Converting(e.FileName, e.Format);
            this.mainGrid.Children.Add(convertingView);
            convertingView.Finished += new EventHandler<VideoConvertFinishedArgs>(convertingView_Finished);
            convertingView.Cancelled += new EventHandler<EventArgs>(convertingView_Cancelled);
        }
        void convertingView_Cancelled(object sender, EventArgs e) {
            RemoveConvertingView((Converting)sender);
            fileSelect = new FileSelect();
            this.mainGrid.Children.Add(fileSelect);
            fileSelect.FileSelected += new EventHandler<VideoSelectedEventArgs>(VideoFileSelected);
        }
        void convertingView_Finished(object sender, VideoConvertFinishedArgs e) {
            RemoveConvertingView((Converting)sender);

        }
        private void RemoveConvertingView(Converting convertingView) {
            this.mainGrid.Children.Remove(convertingView);
            convertingView.Finished -= new EventHandler<VideoConvertFinishedArgs>(convertingView_Finished);
            convertingView.Cancelled -= new EventHandler<EventArgs>(convertingView_Cancelled);
        }
    }
}
