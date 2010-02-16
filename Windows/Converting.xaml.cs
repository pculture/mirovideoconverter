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
        internal Converting(string fileName, VideoFormat format) {
            InitializeComponent();
            if (format == VideoFormat.Theora) {
                string exeDir = IOPath.GetDirectoryName(
                    System.Reflection.Assembly.GetExecutingAssembly().Location);
                string exeName = IOPath.Combine(exeDir, 
                    @"ffmpeg-bin\ffmpeg2theora-0.26.exe");
                string exeArgs = string.Format(
                    "{0} -o {1} --videoquality 8 --audioquality 6", 
                    fileName, IOPath.ChangeExtension(fileName, ".ogv"));
                ProcessOutputHandler.RunProcess(exeName, exeArgs);
            }
            else { 
                
            }
        }

        void cp_OnErrorReceived(object sender, string output) {
            Debug.Print(output);
        }

        void ErrorDataReceived(object sender, DataReceivedEventArgs e) {
            Debug.Print(e.Data);
        }

        void OutputDataReceived(object sender, DataReceivedEventArgs e) {
            Debug.Print(e.Data);
        }
    }
}
