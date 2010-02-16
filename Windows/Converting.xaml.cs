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
        private VideoConverter converter;
        internal Converting(string fileName, VideoFormat format) {
            InitializeComponent();
            converter = new VideoConverter(fileName, format);
            converter.ConvertProgress += 
                new EventHandler<VideoConvertProgressArgs>(converter_ConvertProgress);
            converter.Finished += new EventHandler<EventArgs>(converter_Finished);
            converter.Start();
        }
        void converter_Finished(object sender, EventArgs e) {
            
        }
        void converter_ConvertProgress(object sender, VideoConvertProgressArgs e) {
            
        }
        private void UserControl_Unloaded(object sender, RoutedEventArgs e) {
            converter.Dispose();
        }
    }
}
