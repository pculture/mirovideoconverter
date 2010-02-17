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
        private double initialHeight;

        public MainWindow() {
            InitializeComponent();
            fileSelect.FileSelected += new EventHandler<VideoSelectedEventArgs>(VideoFileSelected);
            initialHeight = this.Height;
        }

        private void VideoFileSelected(object sender, VideoSelectedEventArgs e) {
            this.mainGrid.Children.Remove(fileSelect);
            fileSelect.FileSelected -= new EventHandler<VideoSelectedEventArgs>(VideoFileSelected);
            ShowConvertingView(e.FileName, e.Format);
        }
        private void ShowConvertingView(string fileName, VideoFormat format) {
            Converting convertingView = new Converting(fileName, format);
            this.mainGrid.Children.Add(convertingView);
            convertingView.Margin = new Thickness(0);
            convertingView.HorizontalAlignment = HorizontalAlignment.Stretch;
            convertingView.VerticalAlignment = VerticalAlignment.Stretch;
            convertingView.Finished += new EventHandler<VideoConvertFinishedArgs>(convertingView_Finished);
            convertingView.Cancelled += new EventHandler<EventArgs>(convertingView_Cancelled);
            convertingView.UnknownFormat += new EventHandler<EventArgs>(convertingView_UnknownFormat);
        }
        private void convertingView_UnknownFormat(object sender, EventArgs e) {
            MessageBox.Show("Unknown format");
            SwitchBackToFileSelect(sender);
        }
        private void SwitchBackToFileSelect(object sender) {
            RemoveConvertingView((Converting)sender);
            fileSelect = new FileSelect();
            this.mainGrid.Children.Add(fileSelect);
            fileSelect.FileSelected += new EventHandler<VideoSelectedEventArgs>(VideoFileSelected);
        }
        private void convertingView_Cancelled(object sender, EventArgs e) {
            SwitchBackToFileSelect(sender);
        }
        private void convertingView_Finished(object sender, VideoConvertFinishedArgs e) {
            RemoveConvertingView((Converting)sender);
            Finished finishedView = new Finished(e.outputFileName);
            this.mainGrid.Children.Add(finishedView);
            this.Height = finishedView.Height + 40;
            finishedView.FileSelected += new EventHandler<VideoSelectedEventArgs>(FinishedViewFileSelected);
        }

        private void FinishedViewFileSelected(object sender, VideoSelectedEventArgs e) {
            Finished finishedView = (Finished)sender;
            this.mainGrid.Children.Remove(finishedView);
            finishedView.FileSelected -= new EventHandler<VideoSelectedEventArgs>(FinishedViewFileSelected);
            this.Height = initialHeight;
            ShowConvertingView(e.FileName, e.Format);
        }
        private void RemoveConvertingView(Converting convertingView) {
            this.mainGrid.Children.Remove(convertingView);
            convertingView.Finished -= new EventHandler<VideoConvertFinishedArgs>(convertingView_Finished);
            convertingView.Cancelled -= new EventHandler<EventArgs>(convertingView_Cancelled);
            convertingView.UnknownFormat -= new EventHandler<EventArgs>(convertingView_UnknownFormat);
        }
    }
}
