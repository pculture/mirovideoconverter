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
    /// Interaction logic for UpdateNotification.xaml
    /// </summary>
    public partial class UpdateNotification : Window {
        private string msiURL;

        public UpdateNotification() {
            InitializeComponent();
        }
        public string MSIURL {
            set {
                this.msiURL = value;
            }
        }
        private void NotNowClicked(object sender, RoutedEventArgs e) {
            this.Close();
        }
        private void GetNewVersionClicked(object sender, RoutedEventArgs e) {
            System.Diagnostics.Process.Start(msiURL);
            Application.Current.Shutdown();
        }
    }
}
