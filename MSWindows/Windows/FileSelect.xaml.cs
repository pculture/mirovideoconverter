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
using Microsoft.Win32;
using IOPath = System.IO.Path;
using Mirosubs.Converter.Windows.ConversionFormats;
using Mirosubs.Converter.Windows.Properties;

namespace Mirosubs.Converter.Windows {
    public partial class FileSelect : UserControl {
        internal event EventHandler<VideoSelectedEventArgs> FileSelected;

        private string selectedFileName = null;

        public FileSelect() {
            InitializeComponent();
            ((CollectionViewSource)this.Resources["GroupedVideoFormats"]).Source = ConversionFormat.All;
        }
        public string FinishedFileName { get; set; }
        private void WasLoaded(object sender, RoutedEventArgs e) {
            ConversionFormat format = 
                ConversionFormat.FindByDisplayName(
                    Settings.Default.LastFormatDisplayName);
            if (format == null)
                format = TheoraVideoFormat.Theora;
            videoFormatCombo.SelectedValue = format;
            if (FinishedFileName != null) {
                topLabel.Visibility = Visibility.Hidden;
                finishedGrid.Visibility = Visibility.Visible;
                finishedTextBlock.Text = string.Format("Finished converting {0}",
                   IOPath.GetFileName(FinishedFileName));
            }
        }
        private void FilesDropped(object sender, DragEventArgs e) {
            if (e.Data.GetDataPresent(DataFormats.FileDrop)) {
                string[] droppedFilePaths =
                    (string[])e.Data.GetData(DataFormats.FileDrop, true);
                if (droppedFilePaths.Length > 1) {
                    MessageBox.Show("You can only drop one file at a time.");
                    return;
                }
                DisplayFile(droppedFilePaths[0]);
            }
        }
        private void ChooseFileClicked(object sender, EventArgs e) {
            OpenFileDialog dlg = new OpenFileDialog();
            if (dlg.ShowDialog() == true)
                DisplayFile(dlg.FileName);
        }
        private void DisplayFile(string filePath) {
            this.selectedFileName = filePath;
            topLabel.Content = "Ready to Convert!";
            convertLabel.Content = "to select a different video, drag it here or";
            convertGrid.VerticalAlignment = VerticalAlignment.Bottom;
            convertGrid.Margin = new Thickness(0d, 0d, 0d, 5d);
            string fileName = IOPath.GetFileName(filePath);
            fileNameTextBlock.Text = fileName;
            fileNameTextBlock.Visibility = Visibility.Visible;
        }

        private void ConvertClicked(object sender, RoutedEventArgs e) {
            if (this.selectedFileName == null) {
                MessageBox.Show("You must specify a file first.");
                return;
            }
            if (videoFormatCombo.SelectedValue == null) {
                MessageBox.Show("You must select a format first.");
                return;
            }
            ConversionFormat selectedFormat = 
                (ConversionFormat)videoFormatCombo.SelectedValue;
            Settings.Default.LastFormatDisplayName =
                selectedFormat.DisplayName;
            Settings.Default.Save();
            if (FileSelected != null)
                FileSelected(this, new VideoSelectedEventArgs(
                    selectedFileName, 
                    selectedFormat,
                    (sendToITunes.IsChecked.HasValue && 
                    sendToITunes.IsChecked.Value)));
        }

        private void AboutHelpClicked(object sender, EventArgs e) {
            AboutHelp aboutHelp = new AboutHelp();
            aboutHelp.ShowDialog();
        }

        private void ShowFinishedFile(object sender, EventArgs e) {
            System.Diagnostics.Process.Start(IOPath.GetDirectoryName(FinishedFileName));
        }

        private void videoFormatCombo_SelectionChanged(object sender, SelectionChangedEventArgs e) {
            ConversionFormat selectedValue = 
                (ConversionFormat)videoFormatCombo.SelectedValue;
            sendToITunes.Visibility =
                (selectedValue.Group == VideoFormatGroup.Apple ?
                Visibility.Visible : Visibility.Hidden);
        }
    }
}
