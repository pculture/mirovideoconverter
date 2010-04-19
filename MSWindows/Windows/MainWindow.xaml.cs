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
using System.Threading;
using Mirosubs.Converter.Windows.VideoFormats;
using Mirosubs.Converter.Windows.Process;

namespace Mirosubs.Converter.Windows {
    /// <summary>
    /// Interaction logic for Window1.xaml
    /// </summary>
    public partial class MainWindow : Window {
        private const string VERSION_URL =
            "http://ftp.osuosl.org/pub/pculture.org/mirovideoconverter/MiroConverterVersion.xml";
        private const string MSI_URL = "http://mirovideoconverter.com";

        public MainWindow() {
            InitializeComponent();
            Thread updateThread = new Thread(
                new ThreadStart(this.CheckForUpdates));
            updateThread.Start();
            fileSelect.FileSelected += 
                new EventHandler<VideoSelectedEventArgs>(
                    VideoFileSelected);
        }
        private void CheckForUpdates() {
            try {
                Updater updater = new Updater();
                updater.NeedsUpdateHandler +=
                    new EventHandler<EventArgs>(NeedsUpdate);
                updater.CheckForUpdate(VERSION_URL);
            }
            catch (Exception) {
                // just eat it.
            }
        }
        private void NeedsUpdate(object sender, EventArgs args) {
            if (this.Dispatcher.CheckAccess()) {
                UpdateNotification updateNotification =
                    new UpdateNotification();
                updateNotification.MSIURL = MSI_URL;
                updateNotification.ShowDialog();
            }
            else
                this.Dispatcher.Invoke((Action)(() => 
                    this.NeedsUpdate(sender, args)));
        }
        private void VideoFileSelected(object sender, VideoSelectedEventArgs e) {
            this.mainGrid.Children.Remove(fileSelect);
            fileSelect.FileSelected -= new EventHandler<VideoSelectedEventArgs>(VideoFileSelected);
            ShowConvertingView(e.FileName, e.Format, e.SendToITunesSelected);
        }
        private void ShowConvertingView(string fileName, VideoFormat format, bool sendToITunesSelected) {
            Converting convertingView = new Converting(fileName, format, sendToITunesSelected);
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
            FileSelect finishedView = new FileSelect();
            finishedView.FinishedFileName = e.outputFileName;
            this.mainGrid.Children.Add(finishedView);
            finishedView.FileSelected += new EventHandler<VideoSelectedEventArgs>(FinishedViewFileSelected);
        }

        private void FinishedViewFileSelected(object sender, VideoSelectedEventArgs e) {
            FileSelect finishedView = (FileSelect)sender;
            this.mainGrid.Children.Remove(finishedView);
            finishedView.FileSelected -= new EventHandler<VideoSelectedEventArgs>(FinishedViewFileSelected);
            ShowConvertingView(e.FileName, e.Format, e.SendToITunesSelected);
        }
        private void RemoveConvertingView(Converting convertingView) {
            this.mainGrid.Children.Remove(convertingView);
            convertingView.Finished -= new EventHandler<VideoConvertFinishedArgs>(convertingView_Finished);
            convertingView.Cancelled -= new EventHandler<EventArgs>(convertingView_Cancelled);
            convertingView.UnknownFormat -= new EventHandler<EventArgs>(convertingView_UnknownFormat);
        }
    }
}
