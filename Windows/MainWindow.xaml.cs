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
        public MainWindow() {
            InitializeComponent();
            fileSelect.FileSelected += new EventHandler<VideoSelectedEventArgs>(VideoFileSelected);
        }

        private void VideoFileSelected(object sender, VideoSelectedEventArgs e) {
            this.mainGrid.Children.Remove(fileSelect);
            this.mainGrid.Children.Add(new Converting(e.FileName, e.Format));
        }


    }
}
