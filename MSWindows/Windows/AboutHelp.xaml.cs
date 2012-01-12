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
using System.Windows.Shapes;
using SProcess = System.Diagnostics.Process;

namespace Mirosubs.Converter.Windows {
    /// <summary>
    /// Interaction logic for AboutHelp.xaml
    /// </summary>
    public partial class AboutHelp : Window {
        public AboutHelp() {
            InitializeComponent();
        }
        private void GetSatisfactionClicked(object sender, EventArgs e) {
            SProcess.Start(@"http://getsatisfaction.com/participatoryculturefoundation/products/participatoryculturefoundation_miro_video_converter");
        }
        private void ViewSourceCode(object sender, EventArgs e) {
            SProcess.Start(@"https://github.com/pculture/mirovideoconverter");
        }
        private void ViewPCF(object sender, EventArgs e) {
            SProcess.Start(@"http://pculture.org/");
        }
        private void View8Planes(object sender, EventArgs e) {
            SProcess.Start(@"http://8planes.com/");
        }
    }
}
