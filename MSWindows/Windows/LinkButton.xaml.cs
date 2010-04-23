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
    /// Interaction logic for LinkButton.xaml
    /// </summary>
    public partial class LinkButton : UserControl {
        public static DependencyProperty MouseOverForegroundColorProperty = 
            DependencyProperty.Register("MouseOverForegroundColor", 
            typeof(Brush), typeof(LinkButton));
        public static DependencyProperty ForegroundColorProperty =
            DependencyProperty.Register("ForegroundColor",
            typeof(Brush), typeof(LinkButton));
        public event EventHandler<EventArgs> Clicked;

        public LinkButton() {
            InitializeComponent();
        }
        public Brush MouseOverForegroundColor {
            get { return (Brush)GetValue(MouseOverForegroundColorProperty); }
            set { SetValue(MouseOverForegroundColorProperty, value); }
        }
        public Brush ForegroundColor {
            get { return (Brush)GetValue(ForegroundColorProperty); }
            set { SetValue(ForegroundColorProperty, value); }
        }
        public string ButtonText {
            get { return (string)button.Content; }
            set { button.Content = value; }
        }
        private void button_Click(object sender, RoutedEventArgs e) {
            if (Clicked != null)
                Clicked(this, EventArgs.Empty);
        }
    }
}
