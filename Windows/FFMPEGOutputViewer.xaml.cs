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

namespace Mirosubs.Converter.Windows {
    /// <summary>
    /// Interaction logic for FFMPEGOutputViewer.xaml
    /// </summary>
    public partial class FFMPEGOutputViewer : Window {
        public FFMPEGOutputViewer() {
            InitializeComponent();
        }
        public void AddOutput(string output) {
            this.outputList.Items.Add(output);
        }
    }
}
