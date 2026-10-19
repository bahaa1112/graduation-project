using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;

namespace DIY_Robotics_EducativeCell
{
    /// <summary>
    /// Logique d'interaction pour CloseWindow.xaml
    /// </summary>
    public partial class CloseWindow : Window
    {
        public bool Result { get; private set; }
        public CloseWindow()
        {
            InitializeComponent();
            Result = false;
        }

        private void YesBtn_Click(object sender, RoutedEventArgs e)
        {
            if (GlobalVars.RobotConnected == true)
            {
                GlobalVars.portCloseRequest = true;            
                while (GlobalVars.okToClose == false)
                {
                }
            }         
            Result = true;
            this.Close();
        }

        private void NoBtn_Click(object sender, RoutedEventArgs e)
        {
            Result = false;
            this.Close();
        }
    }
}
