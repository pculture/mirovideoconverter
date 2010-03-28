//  MiroVideoConverter -- a super simple way to convert almost any video to MP4, 
//  Ogg Theora, or a specific phone or iPod.
//
//  Copyright 2010 Participatory Culture Foundation
//
//  This file is part of MiroVideoConverter.
//
//  MiroVideoConverter is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  MiroVideoConverter is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with MiroVideoConverter.  If not, see http://www.gnu.org/licenses/.

﻿using System;
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
using Mirosubs.Converter.Windows.VideoFormats;
using Mirosubs.Converter.Windows.Process;

namespace Mirosubs.Converter.Windows {
    /// <summary>
    /// Interaction logic for Converting.xaml
    /// </summary>
    public partial class Converting : UserControl {
        internal event EventHandler<EventArgs> Cancelled;
        internal event EventHandler<VideoConvertFinishedArgs> Finished;
        internal event EventHandler<EventArgs> UnknownFormat;

        private VideoConverter converter;
        private List<string> ffmpegOutput;
        private FFMPEGOutputViewer ffmpegOutputViewer = null;

        internal Converting(string fileName, VideoFormat format) {
            InitializeComponent();
            this.ffmpegOutput = new List<string>();
            fileNameLabel.Content = IOPath.GetFileName(fileName);
            progressLabel.Content = "Starting...";
            converter = format.MakeConverter(fileName);
            converter.Output += new EventHandler<ProcessOutputArgs>(converter_FFMPEGOutput);
            converter.ConvertProgress += 
                new EventHandler<VideoConvertProgressArgs>(converter_ConvertProgress);
            converter.Finished += new EventHandler<EventArgs>(converter_Finished);
            converter.UnknownFormat += new EventHandler<EventArgs>(converter_UnknownFormat);
            converter.Start();
        }

        void converter_UnknownFormat(object sender, EventArgs e) {
            if (this.Dispatcher.CheckAccess()) {
                if (UnknownFormat != null)
                    UnknownFormat(this, e);
            }
            else
                this.Dispatcher.Invoke((Action)(() => this.converter_UnknownFormat(sender, e)));
        }
        private void converter_FFMPEGOutput(object sender, ProcessOutputArgs e) {
            if (this.Dispatcher.CheckAccess()) {
                ffmpegOutput.Add(e.OutputLine);
                if (ffmpegOutputViewer != null)
                    ffmpegOutputViewer.AddOutput(e.OutputLine);
            }
            else
                this.Dispatcher.Invoke((Action)(() => this.converter_FFMPEGOutput(sender, e)));
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
            MessageBoxResult result =
                MessageBox.Show("Are you sure you want to cancel?",
                "Cancel?", MessageBoxButton.YesNo);
            if (result == MessageBoxResult.Yes) {
                converter.Cancel();
                if (Cancelled != null)
                    Cancelled(this, new EventArgs());
            }
        }
        private void ShowFFMPEGOutput(object sender, RoutedEventArgs e) {
            ffmpegOutputViewer = new FFMPEGOutputViewer();
            ffmpegOutput.ForEach(str => ffmpegOutputViewer.AddOutput(str));
            ffmpegOutputViewer.Show();
        }
    }
}
