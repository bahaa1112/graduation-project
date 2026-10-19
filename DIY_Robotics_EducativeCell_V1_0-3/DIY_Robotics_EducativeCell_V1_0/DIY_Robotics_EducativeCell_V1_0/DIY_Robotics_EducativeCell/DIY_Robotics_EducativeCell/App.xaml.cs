using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using System.Windows;

namespace DIY_Robotics_EducativeCell
{
    /// <summary>
    /// Global variables declaration
    /// </summary>
    /// 
    public static class GlobalVars
    {
        //*************************************************  BYTE *********************************************************
        public static byte J1deg;
        public static byte J2deg;
        public static byte J3deg;
        public static byte J4deg;
        public static byte J5deg;
        public static byte J6deg;

        public static byte Cmd_J1;
        public static byte Cmd_J2;
        public static byte Cmd_J3;
        public static byte Cmd_J4;
        public static byte Cmd_J5;
        public static byte Cmd_J6;
        public static byte Cmd_Di1;
        public static byte Cmd_Di2;
        public static byte Cmd_Di3;
        public static byte Cmd_Do1;
        public static byte Cmd_Do2;
        public static byte Cmd_Do3;

        public static byte JogSpeed;

        public static byte[,] prog1InstByte = new byte[200, 8];

        //*************************************************  STRING *********************************************************
        public static string J1degStr;
        public static string J2degStr;
        public static string J3degStr;
        public static string J4degStr;
        public static string J5degStr;
        public static string J6degStr;

        public static string PopUpType;
        public static string PopUpArg1;
        public static string PopUpArg2;

        public static string[,] prog1InstString = new string[200, 16];


        //*************************************************  BOOL *********************************************************
        public static bool Di1;
        public static bool Di2;
        public static bool Di3;
        public static bool Do1;
        public static bool Do2;
        public static bool Do3;

        public static bool RobotConnected;
        public static bool SimulationMode;
        public static bool PacketReceived;

        public static bool ExeLineRequest;
        public static bool AutoRequest;

        public static bool BtnsJogIsEn;
        public static bool BtnsSpeedIsEn;
        public static bool BtnsMenuIsEn;
        public static bool BtnsMenuConnectIsEn;
        public static bool BtnPopUpIsEn;
        public static bool Btn4IsEn;

        public static bool eStopState;

        public static bool portCloseRequest;
        public static bool okToClose;

        //*************************************************  INT *********************************************************
        public static int prog1ActiveLine;
    }

    public partial class App : Application
    {
    }
}
