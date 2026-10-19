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
using System.IO.Ports;
using System.Threading;

namespace DIY_Robotics_EducativeCell
{
    /// <summary>
    /// Page_Connect.xaml.cs
    /// 
    /// Btn_ScanSerial_Clicked      -> Scans available serial ports
    /// Btn_PortConnect_Clicked     -> Opens a serial communication on the selected port
    /// PortWrite                   -> Sends data on serial port
    /// serialPort_DataReceived     -> Receive data from robot on serial port
    /// processData                 -> Determines if we have a "packet" in the queue
    /// Btn_Simulation_Clicked      -> Enables Simulation mode
    /// 
    /// Background Logic 1          -> Sends data to robot on serial port
    /// Background Logic 2          -> Updates data in "Connect" page 
    /// </summary>
    public partial class Page_Connect : Page
    {

        string message0 = " ";
        string message1 = " ";
        string message2 = "  No device were found. Try to scan again.";
        string message3 = "  Device found on following ports:";
        string message4 = "  Wait data from Robot";
        string message5 = "  Robot has been successfully connected.";
        string[] portscan = new string[5];

        static SerialPort robotPort;

        private Queue<byte> recievedData = new Queue<byte>();

        int myTmpInt;

        byte DataIn_J1;
        byte DataIn_J2;
        byte DataIn_J3;
        byte DataIn_J4;
        byte DataIn_J5;
        byte DataIn_J6;
        byte DataIn_Di1;
        byte DataIn_Di2;
        byte DataIn_Di3;
        byte DataIn_Do1;
        byte DataIn_Do2;
        byte DataIn_Do3;
        byte DataIn_robotSpeed;
        byte[] DataOut = new byte[15];

        bool initDone;

        public class DisplayData
        {
            public string message { get; set; }
            public string[] portscanname { get; set; }
        }

        public Page_Connect()
        {
            InitializeComponent();
            this.Loaded += new RoutedEventHandler(Page_Loaded);
            Thread BGL1 = new Thread(BGLogic1);
            Thread BGL2 = new Thread(BGLogic2);

            BGL1.Start();
            BGL2.Start();

            DataIn_J1 = 90;
            DataIn_J2 = 90;
            DataIn_J3 = 90;
            DataIn_J4 = 90;
            DataIn_J5 = 90;
            DataIn_J6 = 90;
            DataIn_Di1 = 0;
            DataIn_Di2 = 0;
            DataIn_Di3 = 0;
            DataIn_Do1 = 0;
            DataIn_Do2 = 0;
            DataIn_Do3 = 0;

            GlobalVars.Cmd_J1 = 90;
            GlobalVars.Cmd_J2 = 90;
            GlobalVars.Cmd_J3 = 90;
            GlobalVars.Cmd_J4 = 90;
            GlobalVars.Cmd_J5 = 90;
            GlobalVars.Cmd_J6 = 90;
            GlobalVars.Cmd_Di1 = 0;
            GlobalVars.Cmd_Di2 = 0;
            GlobalVars.Cmd_Di3 = 0;
            GlobalVars.Cmd_Do1 = 0;
            GlobalVars.Cmd_Do2 = 0;
            GlobalVars.Cmd_Do3 = 0;
            GlobalVars.BtnsMenuConnectIsEn = true;

            GlobalVars.PacketReceived = false;
            initDone = false;
        }

        void Page_Loaded(object sender, RoutedEventArgs e)

        {
            DisplayData s = new DisplayData();
            {
                s.message = message0;
                s.portscanname = portscan;
            };
            this.ConnectPagePanel.DataContext = s;

        }

        //******************************************** Btn_ScanSerial_Clicked **********************************************
        // This function scans available serial ports when the "Scan" Button is clicked.
        private void Btn_ScanSerial_Clicked(object sender, RoutedEventArgs e)
        {
            if (GlobalVars.RobotConnected == false)
            {
                string[] ports = SerialPort.GetPortNames();
                for (int j = 0; j < (portscan.Length); j++)
                {
                    portscan[j] = null;
                }
                if (ports.Length == 0)
                {
                    Console.WriteLine("No serial ports were found:");
                    message0 = message2;
                }
                else
                {
                    Console.WriteLine("The following serial ports were found:");
                    message0 = message3;

                    int i = 0;
                    foreach (string port in ports)
                    {
                        portscan[i] = port;
                        i++;
                        //Console.WriteLine(port);
                    }
                    //Console.ReadLine();
                }
            }
        }

        //******************************************** Btn_PortConnect_Clicked **********************************************
        // This function opens a serial communication on the selected port when the "Connect" button is clicked.
        private void Btn_PortConnect_Clicked(object sender, RoutedEventArgs e)
        {

            int comboBoxIndex = portComboBox.SelectedIndex;
            string comboBoxValue = portscan[comboBoxIndex];

            if (comboBoxValue != null)
            {
                if (robotPort == null)
                {
                    robotPort = new SerialPort(comboBoxValue, 9600);//Set your board COM
                    robotPort.DataReceived += serialPort_DataReceived;
                    // Set the read/write timeouts
                    robotPort.ReadTimeout = 500;
                    robotPort.WriteTimeout = 500;
                    robotPort.Open();
                    Thread.Sleep(10);
                    GlobalVars.RobotConnected = true;
                    GlobalVars.SimulationMode = false;
                    message0 = message4;
                }
            }
        }

        //******************************************** PortWrite **********************************************
        // This function sends data on the serial port (to robot).
        private void PortWrite(string message)
        {
            robotPort.Write(message);
        }

        //******************************************** serialPort_DataReceived **********************************************
        // This function reads data on the serial port (from robot).
        // If data packet is recognized, global variables of robot axis angles and digital inputs states are updated.
        void serialPort_DataReceived(object s, SerialDataReceivedEventArgs e)
        {
            byte[] data = new byte[robotPort.BytesToRead];
            robotPort.Read(data, 0, data.Length);
            data.ToList().ForEach(b => recievedData.Enqueue(b));
            processData();
            if (data.Length == 15)
            {
                if (data[0] == 253 & data[14] == 254)
                {
                    DataIn_J1 = data[1];
                    DataIn_J2 = data[2];
                    DataIn_J3 = data[3];
                    DataIn_J4 = data[4];
                    DataIn_J5 = data[5];
                    DataIn_J6 = data[6];
                    DataIn_Di1 = data[7];
                    DataIn_Di2 = data[8];
                    DataIn_Di3 = data[9];
                    DataIn_Do1 = data[10];
                    DataIn_Do2 = data[11];
                    DataIn_Do3 = data[12];
                    DataIn_robotSpeed = data[13];

                    GlobalVars.J1deg = DataIn_J1;
                    GlobalVars.J2deg = DataIn_J2;
                    GlobalVars.J3deg = DataIn_J3;
                    GlobalVars.J4deg = DataIn_J4;
                    GlobalVars.J5deg = DataIn_J5;
                    GlobalVars.J6deg = DataIn_J6;
                    if (DataIn_Di1 == 0)
                    {
                        GlobalVars.Di1 = false;
                    }
                    else if(DataIn_Di1 == 1)
                    {
                        GlobalVars.Di1 = true;
                    }
                    if (DataIn_Di2 == 0)
                    {
                        GlobalVars.Di2 = false;
                    }
                    else if (DataIn_Di2 == 1)
                    {
                        GlobalVars.Di2 = true;
                    }
                    if (DataIn_Di3 == 0)
                    {
                        GlobalVars.Di3 = false;
                    }
                    else if (DataIn_Di3 == 1)
                    {
                        GlobalVars.Di3 = true;
                    }
                    GlobalVars.PacketReceived = true;
                }
            }
        }

        //******************************************** processData **********************************************
        // This function determines if we have a "packet" in the queue.
        void processData()
        {
            if (recievedData.Count > 50)
            {
                var packet = Enumerable.Range(0, 50).Select(i => recievedData.Dequeue());
            }
        }

        //******************************************** Btn_Simulation_Clicked **********************************************
        // This function enable Simulation mode when "Simulation mode" is clicked.
        private void Btn_Simulation_Clicked(object sender, RoutedEventArgs e)
        {
            GlobalVars.SimulationMode = true;
            GlobalVars.BtnsMenuIsEn = true;
        }

        ///    *********************************************     Background Logic 1    *******************************************************
        ///    // This Background Logic sends data on serial port to communicate with robot
        public void BGLogic1()
        {
         
            while (true)
            {
                    if(GlobalVars.RobotConnected == true)
                    { 
                    DataOut[0] = 253;
                    DataOut[1] = GlobalVars.Cmd_J1;
                    DataOut[2] = GlobalVars.Cmd_J2;
                    DataOut[3] = GlobalVars.Cmd_J3;
                    DataOut[4] = GlobalVars.Cmd_J4;
                    DataOut[5] = GlobalVars.Cmd_J5;
                    DataOut[6] = GlobalVars.Cmd_J6;
                    DataOut[7] = GlobalVars.Cmd_Di1;
                    DataOut[8] = GlobalVars.Cmd_Di2;
                    DataOut[9] = GlobalVars.Cmd_Di3;
                    DataOut[10] = GlobalVars.Cmd_Do1;
                    DataOut[11] = GlobalVars.Cmd_Do2;
                    DataOut[12] = GlobalVars.Cmd_Do3;
                    DataOut[13] = GlobalVars.JogSpeed;
                    DataOut[14] = 254;

                    robotPort.Write(DataOut, 0, 15);
                    
                    myTmpInt = GlobalVars.J1deg;
                    GlobalVars.J1degStr = myTmpInt.ToString();
                    myTmpInt = GlobalVars.J2deg;
                    GlobalVars.J2degStr = myTmpInt.ToString();
                    myTmpInt = GlobalVars.J3deg;
                    GlobalVars.J3degStr = myTmpInt.ToString();
                    myTmpInt = GlobalVars.J4deg;
                    GlobalVars.J4degStr = myTmpInt.ToString();
                    myTmpInt = GlobalVars.J5deg;
                    GlobalVars.J5degStr = myTmpInt.ToString();
                    myTmpInt = GlobalVars.J6deg;
                    GlobalVars.J6degStr = myTmpInt.ToString();

                }

                if(GlobalVars.portCloseRequest == true)
                {
                    GlobalVars.RobotConnected = false;
                    Thread.Sleep(250);
                    robotPort.Close();
                    Thread.Sleep(250);
                    GlobalVars.okToClose = true;
                }
                Thread.Sleep(10);
            }
        }

        ///    *********************************************     Background Logic 2    *******************************************************
        ///    // This Background Logic updates data in the "Connect" Page
        public void BGLogic2()
        {
            while (true)
            {
                Dispatcher.Invoke(() => {
                    DisplayData s = new DisplayData();
                    {
                        s.message = message0;
                        s.portscanname = portscan;
                        Btn_SimulationMode.IsEnabled = GlobalVars.BtnsMenuConnectIsEn;

                    };
                    this.ConnectPagePanel.DataContext = s;
                });

                if((GlobalVars.RobotConnected == true) & (GlobalVars.PacketReceived == true) & (initDone == false))
                { 
                    message0 = message5;
                    GlobalVars.BtnsJogIsEn = true;
                    GlobalVars.BtnsSpeedIsEn = true;
                    GlobalVars.BtnsMenuIsEn = true;
                    GlobalVars.BtnsMenuConnectIsEn = false;
                    initDone = true;
                }               

                Thread.Sleep(100);
            }
        }

    }
}
