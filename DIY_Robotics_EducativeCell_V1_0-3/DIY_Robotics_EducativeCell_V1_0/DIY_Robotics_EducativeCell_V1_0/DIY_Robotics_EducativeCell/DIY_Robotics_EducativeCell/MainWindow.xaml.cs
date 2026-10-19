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
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.Threading;


namespace DIY_Robotics_EducativeCell
{
    /// <summary>
    /// MainWindow.xaml.cs
    /// 
    /// Btn_X_Click                                 -> Change the page content
    /// JXPosButtonMouseDown / JXPosButtonMouseUp   -> Monitors the control buttons state (clicked / released)
    /// SpeedPosButtonClick / SpeedNegButtonClick   -> Increase / decreases robot speed value
    /// Btn_ExeLine_Click                           -> Acknowledges the request to execute a robot program line
    /// Btn_Auto_Click                              -> Acknowledges the request to execute the complete robot program
    /// EstopButtonClick                            -> Acknowledges the request to stop any robot movement commands
    /// ToggleDoXButtonClick                        -> Toggle the digital output commands
    /// 
    /// Background Logic 1                          -> Updates commands for robot axis when control buttons are clicked
    /// Background Logic 2                          -> Updates data in MainWindow
    /// Background Logic 3                          -> Executes robot program
    /// </summary>
    public partial class MainWindow : Window
    {

        bool J1PosButtonClicked;
        bool J2PosButtonClicked;
        bool J3PosButtonClicked;
        bool J4PosButtonClicked;
        bool J5PosButtonClicked;
        bool J6PosButtonClicked;

        bool J1NegButtonClicked;
        bool J2NegButtonClicked;
        bool J3NegButtonClicked;
        bool J4NegButtonClicked;
        bool J5NegButtonClicked;
        bool J6NegButtonClicked;

        bool ExeJ1Done;
        bool ExeJ2Done;
        bool ExeJ3Done;
        bool ExeJ4Done;
        bool ExeJ5Done;
        bool ExeJ6Done;

        bool WaitDiCondTrue;

        int Delay;
        string SpeedStr;

        public class DisplayData
        {

            public string J1PosBind { get; set; }
            public string J2PosBind { get; set; }
            public string J3PosBind { get; set; }
            public string J4PosBind { get; set; }
            public string J5PosBind { get; set; }
            public string J6PosBind { get; set; }
            public string SpeedBind { get; set; }


        }
        public MainWindow()
        {
            InitializeComponent();
            Application.Current.MainWindow.WindowState = WindowState.Maximized;
            this.Loaded += new RoutedEventHandler(Page_Loaded);
            Main.Content = new Page_Connect();

            Thread BGL1 = new Thread(BGLogic1);
            Thread BGL2 = new Thread(BGLogic2);
            Thread BGL3 = new Thread(BGLogic3);

            BGL1.Start();
            BGL2.Start();
            BGL3.Start();

            GlobalVars.J1degStr = "---";
            GlobalVars.J2degStr = "---";
            GlobalVars.J3degStr = "---";
            GlobalVars.J4degStr = "---";
            GlobalVars.J5degStr = "---";
            GlobalVars.J6degStr = "---";
            SpeedStr = "50";

            GlobalVars.J1deg = 0;
            GlobalVars.J2deg = 0;
            GlobalVars.J3deg = 0;
            GlobalVars.J4deg = 0;
            GlobalVars.J5deg = 0;
            GlobalVars.J6deg = 0;

            GlobalVars.ExeLineRequest = false;
            GlobalVars.AutoRequest = false;

            ExeJ1Done = false;
            ExeJ2Done = false;
            ExeJ3Done = false;
            ExeJ4Done = false;
            ExeJ5Done = false;
            ExeJ6Done = false;

            GlobalVars.JogSpeed = 50;

            GlobalVars.portCloseRequest = false;
            GlobalVars.okToClose = false;

        }

        void Page_Loaded(object sender, RoutedEventArgs e)

        {
            DisplayData s = new DisplayData();
            {
                s.J1PosBind = GlobalVars.J1degStr;
                s.J2PosBind = GlobalVars.J2degStr;
                s.J3PosBind = GlobalVars.J3degStr;
                s.J4PosBind = GlobalVars.J4degStr;
                s.J5PosBind = GlobalVars.J5degStr;
                s.J6PosBind = GlobalVars.J6degStr;
                s.SpeedBind = SpeedStr;

            };
            this.mainPageGrid.DataContext = s;
        }

        private void Window_Closing(object sender, System.ComponentModel.CancelEventArgs e)
        {
            CloseWindow window2 = new CloseWindow();
            window2.ShowDialog();

            if (window2.Result == false)
            {
                e.Cancel = true;
            }
        }

        //******************************************** Btn_X_Click **********************************************
        // The following functions change the page content accordingly to clicked button.
        private void Btn_Prog_Click(object sender, RoutedEventArgs e)
        {
            Main.Content = new Page_Prog1();
        }

        private void Btn_Connect_Click(object sender, RoutedEventArgs e)
        {
            Main.Content = new Page_Connect();
        }

        private void Btn_Pos_Click(object sender, RoutedEventArgs e)
        {
            Main.Content = new Page_Position();
        }

        //*************************** JXPosButtonMouseDown / JXPosButtonMouseUp ************************************
        // The following functions monitors the control buttons state (clicked / released)
        private void J1PosButtonMouseDown(object sender, MouseButtonEventArgs e)
        {
            J1PosButtonClicked = true;
        }

        private void J1PosButtonMouseUp(object sender, MouseButtonEventArgs e)
        {
            J1PosButtonClicked = false;
        }

        private void J1NegButtonMouseDown(object sender, MouseButtonEventArgs e)
        {
            J1NegButtonClicked = true;
        }

        private void J1NegButtonMouseUp(object sender, MouseButtonEventArgs e)
        {
            J1NegButtonClicked = false;
        }

        private void J2PosButtonMouseDown(object sender, MouseButtonEventArgs e)
        {
            J2PosButtonClicked = true;
        }

        private void J2PosButtonMouseUp(object sender, MouseButtonEventArgs e)
        {
            J2PosButtonClicked = false;
        }

        private void J2NegButtonMouseDown(object sender, MouseButtonEventArgs e)
        {
            J2NegButtonClicked = true;
        }

        private void J2NegButtonMouseUp(object sender, MouseButtonEventArgs e)
        {
            J2NegButtonClicked = false;
        }

        private void J3PosButtonMouseDown(object sender, MouseButtonEventArgs e)
        {
            J3PosButtonClicked = true;
        }

        private void J3PosButtonMouseUp(object sender, MouseButtonEventArgs e)
        {
            J3PosButtonClicked = false;
        }

        private void J3NegButtonMouseDown(object sender, MouseButtonEventArgs e)
        {
            J3NegButtonClicked = true;
        }

        private void J3NegButtonMouseUp(object sender, MouseButtonEventArgs e)
        {
            J3NegButtonClicked = false;
        }

        private void J4PosButtonMouseDown(object sender, MouseButtonEventArgs e)
        {
            J4PosButtonClicked = true;
        }

        private void J4PosButtonMouseUp(object sender, MouseButtonEventArgs e)
        {
            J4PosButtonClicked = false;
        }

        private void J4NegButtonMouseDown(object sender, MouseButtonEventArgs e)
        {
            J4NegButtonClicked = true;
        }

        private void J4NegButtonMouseUp(object sender, MouseButtonEventArgs e)
        {
            J4NegButtonClicked = false;
        }

        private void J5PosButtonMouseDown(object sender, MouseButtonEventArgs e)
        {
            J5PosButtonClicked = true;
        }

        private void J5PosButtonMouseUp(object sender, MouseButtonEventArgs e)
        {
            J5PosButtonClicked = false;
        }

        private void J5NegButtonMouseDown(object sender, MouseButtonEventArgs e)
        {
            J5NegButtonClicked = true;
        }

        private void J5NegButtonMouseUp(object sender, MouseButtonEventArgs e)
        {
            J5NegButtonClicked = false;
        }

        private void J6PosButtonMouseDown(object sender, MouseButtonEventArgs e)
        {
            J6PosButtonClicked = true;
        }

        private void J6PosButtonMouseUp(object sender, MouseButtonEventArgs e)
        {
            J6PosButtonClicked = false;
        }

        private void J6NegButtonMouseDown(object sender, MouseButtonEventArgs e)
        {
            J6NegButtonClicked = true;
        }

        private void J6NegButtonMouseUp(object sender, MouseButtonEventArgs e)
        {
            J6NegButtonClicked = false;
        }

        //******************************************* SpeedPosButtonClick ************************************************
        // This function increases robot speed value when "Speed +" button is clicked
        private void SpeedPosButtonClick(object sender, RoutedEventArgs e)
        {
            if (GlobalVars.JogSpeed < 100)
            {
                GlobalVars.JogSpeed = (byte)(GlobalVars.JogSpeed + 10);
            }
        }

        //******************************************* SpeedNegButtonClick ************************************************
        // This function decreases robot speed value when "Speed -" button is clicked
        private void SpeedNegButtonClick(object sender, RoutedEventArgs e)
        {
            if (GlobalVars.JogSpeed > 10)
            {
                GlobalVars.JogSpeed = (byte)(GlobalVars.JogSpeed - 10);
            }
        }

        //******************************************* Btn_ExeLine_Click ************************************************
        // This function acknowledges the request to execute a program line when "Execute" button is clicked.
        private void Btn_ExeLine_Click(object sender, RoutedEventArgs e)
        {
            GlobalVars.ExeLineRequest = true;
        }

        //******************************************* Btn_Auto_Click ************************************************
        // This function acknowledges the request to execute the complete program when "Auto" button is clicked.
        private void Btn_Auto_Click(object sender, RoutedEventArgs e)
        {
            GlobalVars.ExeLineRequest = true;
            GlobalVars.AutoRequest = true;
            GlobalVars.prog1ActiveLine = 0;
        }

        //******************************************* EstopButtonClick ************************************************
        // This function acknowledges the request to stop any robot movement commands.
        private void EstopButtonClick(object sender, RoutedEventArgs e)
        {
            if (GlobalVars.eStopState == false)
            {
                GlobalVars.eStopState = true;
                BtnEstop.Background = Brushes.Red;
                GlobalVars.ExeLineRequest = false;
                GlobalVars.AutoRequest = false;
                GlobalVars.BtnsJogIsEn = false;
                GlobalVars.BtnsSpeedIsEn = false;
                GlobalVars.BtnsMenuIsEn = false;
            }
            else
            {
                GlobalVars.eStopState = false;
                BtnEstop.Background = Brushes.LightSalmon;
            }
        }

        //******************************************* ToggleDoXButtonClick ************************************************
        // The following functions toggle the digital output commands when "Toggle" buttons are clicked. 
        private void ToggleDo1ButtonClick(object sender, RoutedEventArgs e)
        {
            if (GlobalVars.Do1 == false)
            {
                GlobalVars.Do1 = true;
                GlobalVars.Cmd_Do1 = 1;
            }
            else if (GlobalVars.Do1 == true)
            {
                GlobalVars.Do1 = false;
                GlobalVars.Cmd_Do1 = 0;
            }
        }
        private void ToggleDo2ButtonClick(object sender, RoutedEventArgs e)
        {
            if (GlobalVars.Do2 == false)
            {
                GlobalVars.Do2 = true;
                GlobalVars.Cmd_Do2 = 1;
            }
            else if (GlobalVars.Do2 == true)
            {
                GlobalVars.Do2 = false;
                GlobalVars.Cmd_Do2 = 0;
            }
        }
        private void ToggleDo3ButtonClick(object sender, RoutedEventArgs e)
        {
            if (GlobalVars.Do3 == false)
            {
                GlobalVars.Do3 = true;
                GlobalVars.Cmd_Do3 = 1;
            }
            else if (GlobalVars.Do3 == true)
            {
                GlobalVars.Do3 = false;
                GlobalVars.Cmd_Do3 = 0;
            }
        }

        ///    *********************************************     Background Logic 1    *******************************************************
        ///    // This Background Logic changes commands on robot axis when control buttons are clicked
        public void BGLogic1()
        {

            while (true)
            {
                if((GlobalVars.ExeLineRequest == false) & (GlobalVars.AutoRequest == false))
                    {
                    if (J1PosButtonClicked == true)
                    {
                        GlobalVars.Cmd_J1 = 180;
                    }
                    if (J1NegButtonClicked == true)
                    {
                        GlobalVars.Cmd_J1 = 0;
                    }
                    if ((J1PosButtonClicked == false) & (J1NegButtonClicked == false))
                    {
                        GlobalVars.Cmd_J1 = GlobalVars.J1deg;
                    }

                    if (J2PosButtonClicked == true)
                    {
                        GlobalVars.Cmd_J2 = 180;
                    }
                    if (J2NegButtonClicked == true)
                    {
                        GlobalVars.Cmd_J2 = 0;
                    }
                    if ((J2PosButtonClicked == false) & (J2NegButtonClicked == false))
                    {
                        GlobalVars.Cmd_J2 = GlobalVars.J2deg;
                    }

                    if (J3PosButtonClicked == true)
                    {
                        GlobalVars.Cmd_J3 = 180;
                    }
                    if (J3NegButtonClicked == true)
                    {
                        GlobalVars.Cmd_J3 = 0;
                    }
                    if ((J3PosButtonClicked == false) & (J3NegButtonClicked == false))
                    {
                        GlobalVars.Cmd_J3 = GlobalVars.J3deg;
                    }

                    if (J4PosButtonClicked == true)
                    {
                        GlobalVars.Cmd_J4 = 180;
                    }
                    if (J4NegButtonClicked == true)
                    {
                        GlobalVars.Cmd_J4 = 0;
                    }
                    if ((J4PosButtonClicked == false) & (J4NegButtonClicked == false))
                    {
                        GlobalVars.Cmd_J4 = GlobalVars.J4deg;
                    }

                    if (J5PosButtonClicked == true)
                    {
                        GlobalVars.Cmd_J5 = 180;
                    }
                    if (J5NegButtonClicked == true)
                    {
                        GlobalVars.Cmd_J5 = 0;
                    }
                    if ((J5PosButtonClicked == false) & (J5NegButtonClicked == false))
                    {
                        GlobalVars.Cmd_J5 = GlobalVars.J5deg;
                    }

                    if (J6PosButtonClicked == true)
                    {
                        GlobalVars.Cmd_J6 = 180;
                    }
                    if (J6NegButtonClicked == true)
                    {
                        GlobalVars.Cmd_J6 = 0;
                    }
                    if ((J6PosButtonClicked == false) & (J6NegButtonClicked == false))
                    {
                        GlobalVars.Cmd_J6 = GlobalVars.J6deg;
                    }

                    Thread.Sleep(10);
                }
            }

        }
        ///    *********************************************     Background Logic 2    *******************************************************
        ///    // This Background Logic updates data in MainWindow
        public void BGLogic2()
        {

            while (true)
            {
                SpeedStr = GlobalVars.JogSpeed.ToString();
                Dispatcher.Invoke(() => {
                    DisplayData s = new DisplayData();
                    {
                        s.J1PosBind = GlobalVars.J1degStr;
                        s.J2PosBind = GlobalVars.J2degStr;
                        s.J3PosBind = GlobalVars.J3degStr;
                        s.J4PosBind = GlobalVars.J4degStr;
                        s.J5PosBind = GlobalVars.J5degStr;
                        s.J6PosBind = GlobalVars.J6degStr;
                        s.SpeedBind = SpeedStr;
                    };
                    this.mainPageGrid.DataContext = s;

                    BtnJ1Pos.IsEnabled = GlobalVars.BtnsJogIsEn;
                    BtnJ2Pos.IsEnabled = GlobalVars.BtnsJogIsEn;
                    BtnJ3Pos.IsEnabled = GlobalVars.BtnsJogIsEn;
                    BtnJ4Pos.IsEnabled = GlobalVars.BtnsJogIsEn;
                    BtnJ5Pos.IsEnabled = GlobalVars.BtnsJogIsEn;
                    BtnJ6Pos.IsEnabled = GlobalVars.BtnsJogIsEn;
                    BtnJ1Neg.IsEnabled = GlobalVars.BtnsJogIsEn;
                    BtnJ2Neg.IsEnabled = GlobalVars.BtnsJogIsEn;
                    BtnJ3Neg.IsEnabled = GlobalVars.BtnsJogIsEn;
                    BtnJ4Neg.IsEnabled = GlobalVars.BtnsJogIsEn;
                    BtnJ5Neg.IsEnabled = GlobalVars.BtnsJogIsEn;
                    BtnJ6Neg.IsEnabled = GlobalVars.BtnsJogIsEn;

                    BtnSpeedPos.IsEnabled = GlobalVars.BtnsSpeedIsEn;
                    BtnSpeedNeg.IsEnabled = GlobalVars.BtnsSpeedIsEn;

                    BtnMenuProg.IsEnabled = GlobalVars.BtnsMenuIsEn;
                    BtnMenuConnect.IsEnabled = GlobalVars.BtnsMenuConnectIsEn;
                    BtnMenuEXE.IsEnabled = GlobalVars.BtnsMenuIsEn;
                    BtnMenuAUTO.IsEnabled = GlobalVars.BtnsMenuIsEn;

                    if (GlobalVars.Do1 == true)
                    {
                        Do1Box.Text = "ON";
                        Do1Box.Background = Brushes.LightGreen;
                    }
                    else if (GlobalVars.Do1 == false)
                    {
                        Do1Box.Text = "OFF";
                        Do1Box.Background = Brushes.LightSalmon;
                    }
                    if (GlobalVars.Do2 == true)
                    {
                        Do2Box.Text = "ON";
                        Do2Box.Background = Brushes.LightGreen;
                    }
                    else if (GlobalVars.Do2 == false)
                    {
                        Do2Box.Text = "OFF";
                        Do2Box.Background = Brushes.LightSalmon;
                    }
                    if (GlobalVars.Do3 == true)
                    {
                        Do3Box.Text = "ON";
                        Do3Box.Background = Brushes.LightGreen;
                    }
                    else if (GlobalVars.Do3 == false)
                    {
                        Do3Box.Text = "OFF";
                        Do3Box.Background = Brushes.LightSalmon;
                    }


                    if (GlobalVars.Di1 == true)
                    {
                        Di1Box.Text = "ON";
                        Di1Box.Background = Brushes.LightGreen;
                    }
                    else if (GlobalVars.Di1 == false)
                    {
                        Di1Box.Text = "OFF";
                        Di1Box.Background = Brushes.LightSalmon;
                    }

                    if (GlobalVars.Di2 == true)
                    {
                        Di2Box.Text = "ON";
                        Di2Box.Background = Brushes.LightGreen;
                    }
                    else if (GlobalVars.Di2 == false)
                    {
                        Di2Box.Text = "OFF";
                        Di2Box.Background = Brushes.LightSalmon;
                    }

                    if (GlobalVars.Di3 == true)
                    {
                        Di3Box.Text = "ON";
                        Di3Box.Background = Brushes.LightGreen;
                    }
                    else if (GlobalVars.Di3 == false)
                    {
                        Di3Box.Text = "OFF";
                        Di3Box.Background = Brushes.LightSalmon;
                    }
                    if (GlobalVars.RobotConnected == true)
                    {
                        ModeBox.Text = "Robot Mode";
                    }
                    else if (GlobalVars.SimulationMode == true)
                    {
                        ModeBox.Text = "Simulation Mode";
                    }

                });
                Thread.Sleep(100);
            }
        }

        ///    *********************************************     Background Logic 3    *******************************************************
        ///    // This Background Logic executes robot program
        public void BGLogic3()
        {

            while (true)
            {
                if(GlobalVars.eStopState == false)
                { 
                    if (GlobalVars.ExeLineRequest == true)
                    {
                        Delay = 10;
                        GlobalVars.BtnsJogIsEn = false;
                        GlobalVars.BtnsSpeedIsEn = false;
                        GlobalVars.BtnsMenuIsEn = false;
                        //******************************************** 
                        //POINT instruction
                        if (GlobalVars.prog1InstByte[GlobalVars.prog1ActiveLine, 0] == 1)
                        {
                            GlobalVars.Cmd_J1 = GlobalVars.prog1InstByte[GlobalVars.prog1ActiveLine, 1];
                            GlobalVars.Cmd_J2 = GlobalVars.prog1InstByte[GlobalVars.prog1ActiveLine, 2];
                            GlobalVars.Cmd_J3 = GlobalVars.prog1InstByte[GlobalVars.prog1ActiveLine, 3];
                            GlobalVars.Cmd_J4 = GlobalVars.prog1InstByte[GlobalVars.prog1ActiveLine, 4];
                            GlobalVars.Cmd_J5 = GlobalVars.prog1InstByte[GlobalVars.prog1ActiveLine, 5];
                            GlobalVars.Cmd_J6 = GlobalVars.prog1InstByte[GlobalVars.prog1ActiveLine, 6];
                            GlobalVars.JogSpeed = GlobalVars.prog1InstByte[GlobalVars.prog1ActiveLine, 7];

                            if (GlobalVars.J1deg == GlobalVars.Cmd_J1)
                            {
                                ExeJ1Done = true;
                            }
                            else
                            {
                                ExeJ1Done = false;
                            }
                            if (GlobalVars.J2deg == GlobalVars.Cmd_J2)
                            {
                                ExeJ2Done = true;
                            }
                            else
                            {
                                ExeJ2Done = false;
                            }
                            if (GlobalVars.J3deg == GlobalVars.Cmd_J3)
                            {
                                ExeJ3Done = true;
                            }
                            else
                            {
                                ExeJ3Done = false;
                            }
                            if (GlobalVars.J4deg == GlobalVars.Cmd_J4)
                            {
                                ExeJ4Done = true;
                            }
                            else
                            {
                                ExeJ4Done = false;
                            }
                            if (GlobalVars.J5deg == GlobalVars.Cmd_J5)
                            {
                                ExeJ5Done = true;
                            }
                            else
                            {
                                ExeJ5Done = false;
                            }
                            if (GlobalVars.J6deg == GlobalVars.Cmd_J6)
                            {
                                ExeJ6Done = true;
                            }
                            else
                            {
                                ExeJ6Done = false;
                            }

                            if ((ExeJ1Done) == true & (ExeJ2Done) == true & (ExeJ3Done) == true & (ExeJ4Done) == true & (ExeJ5Done) == true & (ExeJ6Done) == true)
                            {
                                if (GlobalVars.AutoRequest == true)
                                {
                                    GlobalVars.ExeLineRequest = true;
                                }
                                else
                                {
                                    GlobalVars.ExeLineRequest = false;
                                }
                                if (GlobalVars.prog1ActiveLine < (GlobalVars.prog1InstString.GetLength(0) - 1))
                                {
                                    GlobalVars.prog1ActiveLine++;
                                }
                                else
                                {
                                    GlobalVars.AutoRequest = false;
                                    GlobalVars.ExeLineRequest = false;
                                    GlobalVars.prog1ActiveLine = 0;
                                }
                            }
                        }
                        //******************************************** 
                        //DO instruction
                        else if (GlobalVars.prog1InstByte[GlobalVars.prog1ActiveLine, 0] == 2)
                        {
                            Delay = 250;
                            if (GlobalVars.prog1InstByte[GlobalVars.prog1ActiveLine, 1] == 1)
                            {
                                if (GlobalVars.prog1InstByte[GlobalVars.prog1ActiveLine, 2] == 0)
                                {
                                    GlobalVars.Do1 = false;
                                    GlobalVars.Cmd_Do1 = 0;
                                }
                                else if (GlobalVars.prog1InstByte[GlobalVars.prog1ActiveLine, 2] == 1)
                                {
                                    GlobalVars.Do1 = true;
                                    GlobalVars.Cmd_Do1 = 1;
                                }
                            }
                            else if (GlobalVars.prog1InstByte[GlobalVars.prog1ActiveLine, 1] == 2)
                            {
                                if (GlobalVars.prog1InstByte[GlobalVars.prog1ActiveLine, 2] == 0)
                                {
                                    GlobalVars.Do2 = false;
                                    GlobalVars.Cmd_Do2 = 0;
                                }
                                else if (GlobalVars.prog1InstByte[GlobalVars.prog1ActiveLine, 2] == 1)
                                {
                                    GlobalVars.Do2 = true;
                                    GlobalVars.Cmd_Do2 = 1;
                                }
                            }
                            if (GlobalVars.prog1InstByte[GlobalVars.prog1ActiveLine, 1] == 3)
                            {
                                if (GlobalVars.prog1InstByte[GlobalVars.prog1ActiveLine, 2] == 0)
                                {
                                    GlobalVars.Do3 = false;
                                    GlobalVars.Cmd_Do3 = 0;
                                }
                                else if (GlobalVars.prog1InstByte[GlobalVars.prog1ActiveLine, 2] == 1)
                                {
                                    GlobalVars.Do3 = true;
                                    GlobalVars.Cmd_Do3 = 1;
                                }
                            }
                            if (GlobalVars.AutoRequest == true)
                            {
                                GlobalVars.ExeLineRequest = true;
                            }
                            else
                            {
                                GlobalVars.ExeLineRequest = false;
                            }
                            if (GlobalVars.prog1ActiveLine < (GlobalVars.prog1InstString.GetLength(0) - 1))
                            {
                                GlobalVars.prog1ActiveLine++;
                            }
                            else
                            {
                                GlobalVars.AutoRequest = false;
                                GlobalVars.ExeLineRequest = false;
                                GlobalVars.prog1ActiveLine = 0;
                            }


                        }
                        //******************************************** 
                        //WAITDI instruction
                        else if (GlobalVars.prog1InstByte[GlobalVars.prog1ActiveLine, 0] == 3)
                        {
                            WaitDiCondTrue = false;
                            Delay = 10;
                            if (GlobalVars.prog1InstByte[GlobalVars.prog1ActiveLine, 1] == 1)
                            {
                                if (GlobalVars.prog1InstByte[GlobalVars.prog1ActiveLine, 2] == 0)
                                {
                                    if (GlobalVars.Di1 == false)
                                    {
                                        WaitDiCondTrue = true;
                                    }
                                }
                                else if (GlobalVars.prog1InstByte[GlobalVars.prog1ActiveLine, 2] == 1)
                                {
                                    if (GlobalVars.Di1 == true)
                                    {
                                        WaitDiCondTrue = true;
                                    }
                                }
                            }
                            if (GlobalVars.prog1InstByte[GlobalVars.prog1ActiveLine, 1] == 2)
                            {
                                if (GlobalVars.prog1InstByte[GlobalVars.prog1ActiveLine, 2] == 0)
                                {
                                    if (GlobalVars.Di2 == false)
                                    {
                                        WaitDiCondTrue = true;
                                    }
                                }
                                else if (GlobalVars.prog1InstByte[GlobalVars.prog1ActiveLine, 2] == 1)
                                {
                                    if (GlobalVars.Di2 == true)
                                    {
                                        WaitDiCondTrue = true;
                                    }
                                }
                            }
                            if (GlobalVars.prog1InstByte[GlobalVars.prog1ActiveLine, 1] == 3)
                            {
                                if (GlobalVars.prog1InstByte[GlobalVars.prog1ActiveLine, 2] == 0)
                                {
                                    if (GlobalVars.Di3 == false)
                                    {
                                        WaitDiCondTrue = true;
                                    }
                                }
                                else if (GlobalVars.prog1InstByte[GlobalVars.prog1ActiveLine, 2] == 1)
                                {
                                    if (GlobalVars.Di3 == true)
                                    {
                                        WaitDiCondTrue = true;
                                    }
                                }
                            }
                            if (WaitDiCondTrue == true)
                            {
                                if (GlobalVars.AutoRequest == true)
                                {
                                    GlobalVars.ExeLineRequest = true;
                                }
                                else
                                {
                                    GlobalVars.ExeLineRequest = false;
                                }
                                if (GlobalVars.prog1ActiveLine < (GlobalVars.prog1InstString.GetLength(0) - 1))
                                {
                                    GlobalVars.prog1ActiveLine++;
                                }
                                else
                                {
                                    GlobalVars.AutoRequest = false;
                                    GlobalVars.ExeLineRequest = false;
                                    GlobalVars.prog1ActiveLine = 0;
                                }
                            }

                        }
                        //******************************************** 
                        //JUMP instruction
                        else if (GlobalVars.prog1InstByte[GlobalVars.prog1ActiveLine, 0] == 6)
                        {
                            int tmpInt = 199;
                            for (int i = 0;i< GlobalVars.prog1InstByte.GetLength(0); i++)
                            {
                                if (GlobalVars.prog1InstByte[i,0] == 7)
                                {
                                    if (GlobalVars.prog1InstByte[i, 1] == (GlobalVars.prog1InstByte[GlobalVars.prog1ActiveLine, 1]))
                                    {
                                        tmpInt = i;
                                    }
                                }
                                 
                            }
                            if (GlobalVars.AutoRequest == true)
                            {
                                GlobalVars.ExeLineRequest = true;
                            }
                            else
                            {
                                GlobalVars.ExeLineRequest = false;
                            }
                           
                            GlobalVars.prog1ActiveLine = tmpInt;
                            
                        }
                        else
                        {
                            if (GlobalVars.AutoRequest == true)
                            {
                                GlobalVars.ExeLineRequest = true;
                            }
                            else
                            {
                                GlobalVars.ExeLineRequest = false;
                            }
                            if (GlobalVars.prog1ActiveLine < (GlobalVars.prog1InstString.GetLength(0) - 1))
                            {
                                GlobalVars.prog1ActiveLine++;
                            }
                            else
                            {
                                GlobalVars.AutoRequest = false;
                                GlobalVars.ExeLineRequest = false;
                                GlobalVars.prog1ActiveLine = 0;
                            }
                            Delay = 1;
                        }
                    }
                    else 
                    {
                        if (GlobalVars.RobotConnected == true)
                        {
                            GlobalVars.BtnsJogIsEn = true;
                            GlobalVars.BtnsSpeedIsEn = true;
                            GlobalVars.BtnsMenuIsEn = true;
                        }
                        else if (GlobalVars.SimulationMode == true)
                        {
                            GlobalVars.BtnsMenuIsEn = true;
                        }
                    }
                }
                Thread.Sleep(Delay);

            }

        }

    }
}
