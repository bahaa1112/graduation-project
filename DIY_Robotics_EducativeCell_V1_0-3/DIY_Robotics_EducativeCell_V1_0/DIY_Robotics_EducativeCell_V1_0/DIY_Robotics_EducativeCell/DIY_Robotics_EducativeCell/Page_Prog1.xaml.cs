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
using System.IO;
using Microsoft.Win32;

namespace DIY_Robotics_EducativeCell
{
    /// <summary>
    /// Page_Prog1.xaml.cs
    /// 
    /// Btn_Prog1_UP / Btn_Prog1_DOWN / Btn_Prog1_PageUp / Btn_Prog1_PageDown 
    ///                             -> Manage the active program line
    /// Click_Prog1_AddLine         -> Creates a new blank program line
    /// Click_Prog1_DeleteLine      -> Deletes a program line
    /// Btn_SaveProg_Clicked        -> Saves the robot program 
    /// Btn_LoadProg_Clicked        -> Loads a robot program
    /// Btn_Prog1_Point             -> Fills active line with a POINT instruction
    /// Btn_Prog1_Do                -> Opens popup window to select options in order to fills active line with a DO instruction 
    /// Btn_Prog1_WaitDi            -> Opens popup window to select options in order to fills active line with a WAITDI instruction
    /// Btn_Prog1_JumpLbl           -> Opens popup window to select options in order to fills active line with a JUMP instruction
    /// Btn_popupArgX_X_Clicked     -> Manage the arguments accordingly to selected options in popup window
    /// Btn_popupAdd_Clicked        -> Fills active line with an instruction accordingly to selected options in popup window
    /// Btn_popupCancel_Clicked     -> Closes the popup window
    /// 
    /// Background Logic 1          -> Updates data in "Prog" page
    /// Background Logic 2          -> FREE
    /// </summary>
    public partial class Page_Prog1 : Page
    {
        
        int prog1LineDisplay;

        public Page_Prog1()
        {
            InitializeComponent();
            this.Loaded += new RoutedEventHandler(Page_Loaded);
            
            GlobalVars.prog1ActiveLine = 0;

            Thread BGL1 = new Thread(BGLogic1);
            Thread BGL2 = new Thread(BGLogic2);

            BGL1.Start();
            //BGL2.Start();
        }


        void Page_Loaded(object sender, RoutedEventArgs e)

        {
            prog1LineDisplay = 0;

            Prog1Grid.Width = 750;
            Prog1Grid.Background = new SolidColorBrush(Colors.White);
            Prog1Grid.ShowGridLines = false;

            ColumnDefinition gridCol0 = new ColumnDefinition();
            ColumnDefinition gridCol1 = new ColumnDefinition();
            ColumnDefinition gridCol2 = new ColumnDefinition();
            ColumnDefinition gridCol3 = new ColumnDefinition();
            ColumnDefinition gridCol4 = new ColumnDefinition();
            ColumnDefinition gridCol5 = new ColumnDefinition();
            ColumnDefinition gridCol6 = new ColumnDefinition();
            ColumnDefinition gridCol7 = new ColumnDefinition();
            ColumnDefinition gridCol8 = new ColumnDefinition();
            ColumnDefinition gridCol9 = new ColumnDefinition();
            ColumnDefinition gridCol10 = new ColumnDefinition();
            ColumnDefinition gridCol11 = new ColumnDefinition();
            ColumnDefinition gridCol12 = new ColumnDefinition();
            ColumnDefinition gridCol13 = new ColumnDefinition();
            ColumnDefinition gridCol14 = new ColumnDefinition();
            ColumnDefinition gridCol15 = new ColumnDefinition();

            Prog1Grid.ColumnDefinitions.Add(gridCol0);
            Prog1Grid.ColumnDefinitions.Add(gridCol1);
            Prog1Grid.ColumnDefinitions.Add(gridCol2);
            Prog1Grid.ColumnDefinitions.Add(gridCol3);
            Prog1Grid.ColumnDefinitions.Add(gridCol4);
            Prog1Grid.ColumnDefinitions.Add(gridCol5);
            Prog1Grid.ColumnDefinitions.Add(gridCol6);
            Prog1Grid.ColumnDefinitions.Add(gridCol7);
            Prog1Grid.ColumnDefinitions.Add(gridCol8);
            Prog1Grid.ColumnDefinitions.Add(gridCol9);
            Prog1Grid.ColumnDefinitions.Add(gridCol10);
            Prog1Grid.ColumnDefinitions.Add(gridCol11);
            Prog1Grid.ColumnDefinitions.Add(gridCol12);
            Prog1Grid.ColumnDefinitions.Add(gridCol13);
            Prog1Grid.ColumnDefinitions.Add(gridCol14);
            Prog1Grid.ColumnDefinitions.Add(gridCol15);

            for (int i = 0; i < 15; i++)
            {
                RowDefinition gridRow1 = new RowDefinition();
                gridRow1.Height = new GridLength(25);
                Prog1Grid.RowDefinitions.Add(gridRow1);
            }

            for (int i = 0; i < GlobalVars.prog1InstString.GetLength(0); i++)
            {
                GlobalVars.prog1InstString[i, 0] = i.ToString();
                GlobalVars.prog1InstString[i, 1] = ".";
                GlobalVars.prog1InstString[i, 2] = ".";
                GlobalVars.prog1InstString[i, 3] = ".";
                GlobalVars.prog1InstString[i, 4] = ".";
                GlobalVars.prog1InstString[i, 5] = ".";
                GlobalVars.prog1InstString[i, 6] = ".";
                GlobalVars.prog1InstString[i, 7] = ".";
                GlobalVars.prog1InstString[i, 8] = ".";
                GlobalVars.prog1InstString[i, 9] = ".";
                GlobalVars.prog1InstString[i, 10] = ".";
                GlobalVars.prog1InstString[i, 11] = ".";
                GlobalVars.prog1InstString[i, 12] = ".";
                GlobalVars.prog1InstString[i, 13] = ".";
                GlobalVars.prog1InstString[i, 14] = ".";
                GlobalVars.prog1InstString[i, 15] = ".";
            }

        }

        //******************************************* Btn_Prog1_UP ************************************************
        // This function changes the active program line (1 line up the page).
        private void Btn_Prog1_UP(object sender, RoutedEventArgs e)
        {
            if (GlobalVars.prog1ActiveLine > 0)
            {
                GlobalVars.prog1ActiveLine--;
            }
        }

        //******************************************* Btn_Prog1_DOWN ************************************************
        // This function changes the active program line (1 line down the page).
        private void Btn_Prog1_DOWN(object sender, RoutedEventArgs e)
        {        
            if (GlobalVars.prog1ActiveLine < GlobalVars.prog1InstString.GetLength(0))
            {
                GlobalVars.prog1ActiveLine++;
            }
        }

        //******************************************* Btn_Prog1_PageUp ************************************************
        // This function changes the active program line (10 lines up the page).
        private void Btn_Prog1_PageUp(object sender, RoutedEventArgs e)
        {
            int tmpInt = prog1LineDisplay - 10;
            if (tmpInt < 0)
            {
                tmpInt = 0;
            }
            prog1LineDisplay = tmpInt;
            GlobalVars.prog1ActiveLine = prog1LineDisplay;
        }

        //******************************************* Btn_Prog1_PageDown ************************************************
        // This function changes the active program line (15 lines down the page).
        private void Btn_Prog1_PageDown(object sender, RoutedEventArgs e)
        {
            int tmpInt = prog1LineDisplay + 10;
            if (tmpInt > ((GlobalVars.prog1InstString.GetLength(0)-15)))
            {
                tmpInt = (GlobalVars.prog1InstString.GetLength(0) - 15);
            }
            prog1LineDisplay = tmpInt;
            GlobalVars.prog1ActiveLine = prog1LineDisplay;
        }

        //******************************************* Click_Prog1_AddLine ************************************************
        // This function add a new blank line up the active program line.
        private void Click_Prog1_AddLine(object sender, RoutedEventArgs e)
        {
            for(int i = (GlobalVars.prog1InstString.GetLength(0) - 1); i > GlobalVars.prog1ActiveLine; i--)
            {

                for(int j = 1; j < GlobalVars.prog1InstString.GetLength(1); j++)
                {
                    GlobalVars.prog1InstString[i, j] = GlobalVars.prog1InstString[(i - 1), j];
                }
                for (int j = 0; j < GlobalVars.prog1InstByte.GetLength(1); j++)
                {
                    GlobalVars.prog1InstByte[i, j] = GlobalVars.prog1InstByte[(i - 1), j];
                }

            }
            for (int j = 1; j < GlobalVars.prog1InstString.GetLength(1); j++)
            {
                GlobalVars.prog1InstString[GlobalVars.prog1ActiveLine, j] = ".";
            }
            for (int j = 0; j < GlobalVars.prog1InstByte.GetLength(1); j++)
            {
                GlobalVars.prog1InstByte[GlobalVars.prog1ActiveLine, j] = 0;
            }
        }

        //******************************************* Click_Prog1_DeleteLine ************************************************
        // This function deletes the active program line.
        private void Click_Prog1_DeleteLine(object sender, RoutedEventArgs e)
        {
            for (int i = GlobalVars.prog1ActiveLine; i < (GlobalVars.prog1InstString.GetLength(0) - 1); i++)
            {

                for (int j = 1; j < GlobalVars.prog1InstString.GetLength(1); j++)
                {
                    GlobalVars.prog1InstString[i, j] = GlobalVars.prog1InstString[(i + 1), j];
                }
                for (int j = 0; j < GlobalVars.prog1InstByte.GetLength(1); j++)
                {
                    GlobalVars.prog1InstByte[i, j] = GlobalVars.prog1InstByte[(i + 1), j];
                }

            }
            for (int j = 1; j < GlobalVars.prog1InstString.GetLength(1); j++)
            {
                GlobalVars.prog1InstString[(GlobalVars.prog1InstString.GetLength(0) - 1), j] = ".";
            }
            for (int j = 0; j < GlobalVars.prog1InstByte.GetLength(1); j++)
            {
                GlobalVars.prog1InstByte[(GlobalVars.prog1InstByte.GetLength(0) - 1), j] = 0;
            }
        }

        //******************************************* Btn_SaveProg_Clicked ************************************************
        // This function saves the robot program in a .diy file.
        private void Btn_SaveProg_Clicked(object sender, RoutedEventArgs e)
        {
            //Convert prog1InstString array to one big string

            string[] tmpStringColumn = new string[GlobalVars.prog1InstString.GetLength(0)];
            string[] tmpStringRow = new string[GlobalVars.prog1InstString.GetLength(1)];

            //Convert each prog1InstString row String array into one big string (; is the separator)

            for (int i = 0; i < GlobalVars.prog1InstString.GetLength(0); i++)
            { 
                for (int j = 0; j< GlobalVars.prog1InstString.GetLength(1); j++)
                {
                    tmpStringRow[j] = GlobalVars.prog1InstString[i, j];
               
                }
                tmpStringColumn[i] = String.Join(";", tmpStringRow);
            }

            //Convert new String array into one big string (@ is the separator)
            string result = String.Join("@", tmpStringColumn);

            //Save File
            SaveFileDialog saveFileDialog = new SaveFileDialog();
            saveFileDialog.Filter = "DIY file (*.diy)|*.diy";
            if (saveFileDialog.ShowDialog() == true)
                File.WriteAllText(saveFileDialog.FileName, result);
        }

        //******************************************* Btn_LoadProg_Clicked ************************************************
        // This function loads a robot program (.diy file).
        private void Btn_LoadProg_Clicked(object sender, RoutedEventArgs e)
        {
            string fileData;
            string[,] tmpString1 = new string[200, 16];
            string[] tmpString2 = new string[16];
            int tmpInt;

            OpenFileDialog openFileDialog = new OpenFileDialog();
            openFileDialog.Filter = "DIY file (*.diy)|*.diy";
            if (openFileDialog.ShowDialog() == true)
            {
                string fileName;
                fileName = openFileDialog.FileName;
                if (fileName != null)
                {
                    fileData = File.ReadAllText(openFileDialog.FileName);
                    string[] lines = fileData.Split('@');

                    if (lines.GetLength(0) == 200)
                    {
                        string[] columns = lines[0].Split(';');

                        if (columns.GetLength(0) == 16)
                        {

                            for (int i = 0; i < 200; i++)
                            {
                                tmpString2 = lines[i].Split(';');
                                for (int j = 0; j < 16; j++)
                                {
                                    tmpString1[i, j] = tmpString2[j];
                                }
                            }
                            GlobalVars.prog1InstString = tmpString1;
                        }
                        //Convert tmpString1 to prog1InstByte
                        for (int i = 0; i < 200; i++)
                        {
                            if(tmpString1[i,1] == "POINT")
                            { 
                                GlobalVars.prog1InstByte[i, 0] = 1;
                                tmpInt = Int32.Parse(tmpString1[i, 3]);
                                GlobalVars.prog1InstByte[i, 1] = (byte)tmpInt;
                                tmpInt = Int32.Parse(tmpString1[i, 5]);
                                GlobalVars.prog1InstByte[i, 2] = (byte)tmpInt;
                                tmpInt = Int32.Parse(tmpString1[i, 7]);
                                GlobalVars.prog1InstByte[i, 3] = (byte)tmpInt;
                                tmpInt = Int32.Parse(tmpString1[i, 9]);
                                GlobalVars.prog1InstByte[i, 4] = (byte)tmpInt;
                                tmpInt = Int32.Parse(tmpString1[i, 11]);
                                GlobalVars.prog1InstByte[i, 5] = (byte)tmpInt;
                                tmpInt = Int32.Parse(tmpString1[i, 13]);
                                GlobalVars.prog1InstByte[i, 6] = (byte)tmpInt;
                                tmpInt = Int32.Parse(tmpString1[i, 15]);
                                GlobalVars.prog1InstByte[i, 7] = (byte)tmpInt;
                            }
                            else if (tmpString1[i, 1] == "DO")
                            {
                                GlobalVars.prog1InstByte[i, 0] = 2;

                                if (tmpString1[i, 3] == "Do1")
                                {
                                    GlobalVars.prog1InstByte[i, 1] = 1;
                                }
                                else if (tmpString1[i, 3] == "Do2")
                                {
                                    GlobalVars.prog1InstByte[i, 1] = 2;
                                }
                                else if (tmpString1[i, 3] == "Do3")
                                {
                                    GlobalVars.prog1InstByte[i, 1] = 3;
                                }

                                if (tmpString1[i, 5] == "OFF")
                                {
                                   GlobalVars.prog1InstByte[i, 2] = 0;
                                }
                                else if (tmpString1[i, 5] == "ON")
                                {
                                    GlobalVars.prog1InstByte[i, 2] = 1;
                                }
                                
                            }
                            else if (tmpString1[i, 1] == "WAITDI")
                            {
                                GlobalVars.prog1InstByte[i, 0] = 3;

                                if (tmpString1[i, 3] == "Di1")
                                {
                                    GlobalVars.prog1InstByte[i, 1] = 1;
                                }
                                else if (tmpString1[i, 3] == "Di2")
                                {
                                    GlobalVars.prog1InstByte[i, 1] = 2;
                                }
                                else if (tmpString1[i, 3] == "Di3")
                                {
                                    GlobalVars.prog1InstByte[i, 1] = 3;
                                }

                                if (tmpString1[i, 5] == "OFF")
                                {
                                    GlobalVars.prog1InstByte[i, 2] = 0;
                                }
                                else if (tmpString1[i, 5] == "ON")
                                {
                                    GlobalVars.prog1InstByte[i, 2] = 1;
                                }

                            }
                            else if (tmpString1[i, 1] == "JUMP")
                            {
                                GlobalVars.prog1InstByte[i, 0] = 6;

                                if (tmpString1[i, 3] == "L1")
                                {
                                    GlobalVars.prog1InstByte[i, 1] = 1;
                                }
                                else if (tmpString1[i, 3] == "L2")
                                {
                                    GlobalVars.prog1InstByte[i, 1] = 2;
                                }
                                else if (tmpString1[i, 3] == "L3")
                                {
                                    GlobalVars.prog1InstByte[i, 1] = 3;
                                }
                                else if (tmpString1[i, 3] == "L4")
                                {
                                    GlobalVars.prog1InstByte[i, 1] = 4;
                                }
                                else if (tmpString1[i, 3] == "L5")
                                {
                                    GlobalVars.prog1InstByte[i, 1] = 5;
                                }
                            }
                            else if (tmpString1[i, 1] == "LABEL")
                            {
                                GlobalVars.prog1InstByte[i, 0] = 7;

                                if (tmpString1[i, 3] == "L1")
                                {
                                    GlobalVars.prog1InstByte[i, 1] = 1;
                                }
                                else if (tmpString1[i, 3] == "L2")
                                {
                                    GlobalVars.prog1InstByte[i, 1] = 2;
                                }
                                else if (tmpString1[i, 3] == "L3")
                                {
                                    GlobalVars.prog1InstByte[i, 1] = 3;
                                }
                                else if (tmpString1[i, 3] == "L4")
                                {
                                    GlobalVars.prog1InstByte[i, 1] = 4;
                                }
                                else if (tmpString1[i, 3] == "L5")
                                {
                                    GlobalVars.prog1InstByte[i, 1] = 5;
                                }
                            }

                        }

                    }

                }
            }
        }

        //******************************************* Btn_Prog1_Point ************************************************
        // This function fills the active program line with a POINT instruction.
        private void Btn_Prog1_Point(object sender, RoutedEventArgs e)
        {
            int tmpInt = GlobalVars.prog1ActiveLine;
            GlobalVars.prog1InstByte[tmpInt, 0] = 1;
            GlobalVars.prog1InstByte[tmpInt, 1] = GlobalVars.J1deg;
            GlobalVars.prog1InstByte[tmpInt, 2] = GlobalVars.J2deg;
            GlobalVars.prog1InstByte[tmpInt, 3] = GlobalVars.J3deg;
            GlobalVars.prog1InstByte[tmpInt, 4] = GlobalVars.J4deg;
            GlobalVars.prog1InstByte[tmpInt, 5] = GlobalVars.J5deg;
            GlobalVars.prog1InstByte[tmpInt, 6] = GlobalVars.J6deg;
            GlobalVars.prog1InstByte[tmpInt, 7] = GlobalVars.JogSpeed;

            GlobalVars.prog1InstString[tmpInt, 0] = GlobalVars.prog1ActiveLine.ToString();
            GlobalVars.prog1InstString[tmpInt, 1] = "POINT";
            GlobalVars.prog1InstString[tmpInt, 2] = "J1";
            GlobalVars.prog1InstString[tmpInt, 3] = GlobalVars.prog1InstByte[tmpInt, 1].ToString();
            GlobalVars.prog1InstString[tmpInt, 4] = "J2";
            GlobalVars.prog1InstString[tmpInt, 5] = GlobalVars.prog1InstByte[tmpInt, 2].ToString();
            GlobalVars.prog1InstString[tmpInt, 6] = "J3";
            GlobalVars.prog1InstString[tmpInt, 7] = GlobalVars.prog1InstByte[tmpInt, 3].ToString();
            GlobalVars.prog1InstString[tmpInt, 8] = "J4";
            GlobalVars.prog1InstString[tmpInt, 9] = GlobalVars.prog1InstByte[tmpInt, 4].ToString();
            GlobalVars.prog1InstString[tmpInt, 10] = "J5";
            GlobalVars.prog1InstString[tmpInt, 11] = GlobalVars.prog1InstByte[tmpInt, 5].ToString();
            GlobalVars.prog1InstString[tmpInt, 12] = "J6";
            GlobalVars.prog1InstString[tmpInt, 13] = GlobalVars.prog1InstByte[tmpInt, 6].ToString();
            GlobalVars.prog1InstString[tmpInt, 14] = "SPEED";
            GlobalVars.prog1InstString[tmpInt, 15] = GlobalVars.prog1InstByte[tmpInt, 7].ToString();

            GlobalVars.prog1ActiveLine++;
        }

        //******************************************* Btn_Prog1_Do ************************************************
        // This function fills the active program line with a DO instruction.
        private void Btn_Prog1_Do(object sender, RoutedEventArgs e)
        {
            GlobalVars.PopUpType = "Do";
            GlobalVars.PopUpArg1 = " ";
            GlobalVars.PopUpArg2 = " ";
            BtnArg1_1.Content = "1";
            BtnArg1_2.Content = "2";
            BtnArg1_3.Content = "3";
            BtnArg1_4.Content = " ";
            BtnArg1_5.Content = " ";
            BtnArg2_1.Content = "ON";
            BtnArg2_2.Content = "OFF";
            BtnArg2_3.Content = " ";
            BtnArg2_4.Content = " ";
            BtnArg2_5.Content = " ";
            Arg1PreviewBox.Text = " ";
            Arg2PreviewBox.Text = " ";
            BtnArg1_1.IsEnabled = true;
            BtnArg1_2.IsEnabled = true;
            BtnArg1_3.IsEnabled = true;
            BtnArg1_4.IsEnabled = false;
            BtnArg1_5.IsEnabled = false;
            BtnArg2_1.IsEnabled = false;
            BtnArg2_2.IsEnabled = false;
            BtnArg2_3.IsEnabled = false;
            BtnArg2_4.IsEnabled = false;
            BtnArg2_5.IsEnabled = false;
            BtnPopupAdd.IsEnabled = false;
            Arg1Box.Text = "Choose Do #";
            Arg2Box.Text = "Choose ON / OFF";
            ArgPopup.IsOpen = true;
        }

        //******************************************* Btn_Prog1_JumpLbl ************************************************
        // This function fills the active program line with a JUMP instruction.
        private void Btn_Prog1_JumpLbl(object sender, RoutedEventArgs e)
        {
            GlobalVars.PopUpType = "JumpLbl";
            GlobalVars.PopUpArg1 = " ";
            GlobalVars.PopUpArg2 = " ";
            BtnArg1_1.Content = "Jump";
            BtnArg1_2.Content = "Label";
            BtnArg1_3.Content = " ";
            BtnArg1_4.Content = " ";
            BtnArg1_5.Content = " ";
            BtnArg2_1.Content = "1";
            BtnArg2_2.Content = "2";
            BtnArg2_3.Content = "3";
            BtnArg2_4.Content = "4";
            BtnArg2_5.Content = "5";
            Arg1PreviewBox.Text = " ";
            Arg2PreviewBox.Text = " ";
            BtnArg1_1.IsEnabled = true;
            BtnArg1_2.IsEnabled = true;
            BtnArg1_3.IsEnabled = false;
            BtnArg1_4.IsEnabled = false;
            BtnArg1_5.IsEnabled = false;
            BtnArg2_1.IsEnabled = false;
            BtnArg2_2.IsEnabled = false;
            BtnArg2_3.IsEnabled = false;
            BtnArg2_4.IsEnabled = false;
            BtnArg2_5.IsEnabled = false;
            BtnPopupAdd.IsEnabled = false;
            Arg1Box.Text = "Choose Jump/Label";
            Arg2Box.Text = "Choose Label #";
            ArgPopup.IsOpen = true;
        }

        //******************************************* Btn_Prog1_WaitDi ************************************************
        // This function fills the active program line with a WAITDI instruction.
        private void Btn_Prog1_WaitDi(object sender, RoutedEventArgs e)
        {
            GlobalVars.PopUpType = "WaitDi";
            GlobalVars.PopUpArg1 = " ";
            GlobalVars.PopUpArg2 = " ";
            BtnArg1_1.Content = "1";
            BtnArg1_2.Content = "2";
            BtnArg1_3.Content = "3";
            BtnArg1_4.Content = " ";
            BtnArg1_5.Content = " ";
            BtnArg2_1.Content = "ON";
            BtnArg2_2.Content = "OFF";
            BtnArg2_3.Content = " ";
            BtnArg2_4.Content = " ";
            BtnArg2_5.Content = " ";
            Arg1PreviewBox.Text = " ";
            Arg2PreviewBox.Text = " ";
            BtnArg1_1.IsEnabled = true;
            BtnArg1_2.IsEnabled = true;
            BtnArg1_3.IsEnabled = true;
            BtnArg1_4.IsEnabled = false;
            BtnArg1_5.IsEnabled = false;
            BtnArg2_1.IsEnabled = false;
            BtnArg2_2.IsEnabled = false;
            BtnArg2_3.IsEnabled = false;
            BtnArg2_4.IsEnabled = false;
            BtnArg2_5.IsEnabled = false;
            BtnPopupAdd.IsEnabled = false;
            Arg1Box.Text = "Choose Di #";
            Arg2Box.Text = "Choose ON / OFF";
            ArgPopup.IsOpen = true;
        }

        //******************************************* Btn_popupArgX_X_Clicked ************************************************
        // The following functions manage the different arguments when an option is selected in the insctruction popupwindow.
        private void Btn_popupArg1_1_Clicked(object sender, RoutedEventArgs e)
        {
            if(GlobalVars.PopUpType == "Do")
            { 
                GlobalVars.PopUpArg1 = "Do1";
                Arg1PreviewBox.Text = "Do1";
                BtnArg2_1.IsEnabled = true;
                BtnArg2_2.IsEnabled = true;
            }
            else if(GlobalVars.PopUpType == "WaitDi")
            {
                GlobalVars.PopUpArg1 = "Di1";
                Arg1PreviewBox.Text = "Di1";
                BtnArg2_1.IsEnabled = true;
                BtnArg2_2.IsEnabled = true;
            }
            else if (GlobalVars.PopUpType == "JumpLbl")
            {
                GlobalVars.PopUpArg1 = "JUMP";
                Arg1PreviewBox.Text = "JUMP";
                BtnArg2_1.IsEnabled = true;
                BtnArg2_2.IsEnabled = true;
                BtnArg2_3.IsEnabled = true;
                BtnArg2_4.IsEnabled = true;
                BtnArg2_5.IsEnabled = true;
            }
        }
        private void Btn_popupArg1_2_Clicked(object sender, RoutedEventArgs e)
        {
            if (GlobalVars.PopUpType == "Do")
            {
                GlobalVars.PopUpArg1 = "Do2";
                Arg1PreviewBox.Text = "Do2";
                BtnArg2_1.IsEnabled = true;
                BtnArg2_2.IsEnabled = true;
            }
            else if (GlobalVars.PopUpType == "WaitDi")
            {
                GlobalVars.PopUpArg1 = "Di2";
                Arg1PreviewBox.Text = "Di2";
                BtnArg2_1.IsEnabled = true;
                BtnArg2_2.IsEnabled = true;
            }
            else if (GlobalVars.PopUpType == "JumpLbl")
            {
                GlobalVars.PopUpArg1 = "LABEL";
                Arg1PreviewBox.Text = "LABEL";
                BtnArg2_1.IsEnabled = true;
                BtnArg2_2.IsEnabled = true;
                BtnArg2_3.IsEnabled = true;
                BtnArg2_4.IsEnabled = true;
                BtnArg2_5.IsEnabled = true;
            }
        }
        private void Btn_popupArg1_3_Clicked(object sender, RoutedEventArgs e)
        {
            if (GlobalVars.PopUpType == "Do")
            {
                GlobalVars.PopUpArg1 = "Do3";
                Arg1PreviewBox.Text = "Do3";
                BtnArg2_1.IsEnabled = true;
                BtnArg2_2.IsEnabled = true;
            }
            else if(GlobalVars.PopUpType == "WaitDi")
            {
                GlobalVars.PopUpArg1 = "Di3";
                Arg1PreviewBox.Text = "Di3";
                BtnArg2_1.IsEnabled = true;
                BtnArg2_2.IsEnabled = true;
            }
            else if (GlobalVars.PopUpType == "JumpLbl")
            {

            }

        }
        private void Btn_popupArg1_4_Clicked(object sender, RoutedEventArgs e)
        {
            if (GlobalVars.PopUpType == "Do")
            {

            }
            else if (GlobalVars.PopUpType == "WaitDi")
            {

            }
            else if (GlobalVars.PopUpType == "JumpLbl")
            {

            }

        }
        private void Btn_popupArg1_5_Clicked(object sender, RoutedEventArgs e)
        {
            if (GlobalVars.PopUpType == "Do")
            {

            }
            else if (GlobalVars.PopUpType == "WaitDi")
            {

            }
            else if (GlobalVars.PopUpType == "JumpLbl")
            {

            }

        }
        private void Btn_popupArg2_1_Clicked(object sender, RoutedEventArgs e)
        {

            if (GlobalVars.PopUpType == "Do")
            {
                GlobalVars.PopUpArg2 = "ON";
                Arg2PreviewBox.Text = "ON";
                BtnPopupAdd.IsEnabled = true;

            }
            else if (GlobalVars.PopUpType == "WaitDi")
            {
                GlobalVars.PopUpArg2 = "ON";
                Arg2PreviewBox.Text = "ON";
                BtnPopupAdd.IsEnabled = true;

            }
            else if (GlobalVars.PopUpType == "JumpLbl")
            {
                GlobalVars.PopUpArg2 = "L1";
                Arg2PreviewBox.Text = "L1";
                BtnPopupAdd.IsEnabled = true;
            }

        }
        private void Btn_popupArg2_2_Clicked(object sender, RoutedEventArgs e)
        {
            if (GlobalVars.PopUpType == "Do")
            {
                GlobalVars.PopUpArg2 = "OFF";
                Arg2PreviewBox.Text = "OFF";
                BtnPopupAdd.IsEnabled = true;

            }
            else if (GlobalVars.PopUpType == "WaitDi")
            {
                GlobalVars.PopUpArg2 = "OFF";
                Arg2PreviewBox.Text = "OFF";
                BtnPopupAdd.IsEnabled = true;

            }
            else if (GlobalVars.PopUpType == "JumpLbl")
            {
                GlobalVars.PopUpArg2 = "L2";
                Arg2PreviewBox.Text = "L2";
                BtnPopupAdd.IsEnabled = true;
            }
        }
        private void Btn_popupArg2_3_Clicked(object sender, RoutedEventArgs e)
        {
            if (GlobalVars.PopUpType == "Do")
            {


            }
            else if (GlobalVars.PopUpType == "WaitDi")
            {


            }
            else if (GlobalVars.PopUpType == "JumpLbl")
            {
                GlobalVars.PopUpArg2 = "L3";
                Arg2PreviewBox.Text = "L3";
                BtnPopupAdd.IsEnabled = true;
            }
        }
        private void Btn_popupArg2_4_Clicked(object sender, RoutedEventArgs e)
        {
            if (GlobalVars.PopUpType == "Do")
            {


            }
            else if (GlobalVars.PopUpType == "WaitDi")
            {


            }
            else if (GlobalVars.PopUpType == "JumpLbl")
            {
                GlobalVars.PopUpArg2 = "L4";
                Arg2PreviewBox.Text = "L4";
                BtnPopupAdd.IsEnabled = true;
            }
        }
        private void Btn_popupArg2_5_Clicked(object sender, RoutedEventArgs e)
        {
            if (GlobalVars.PopUpType == "Do")
            {


            }
            else if (GlobalVars.PopUpType == "WaitDi")
            {


            }
            else if (GlobalVars.PopUpType == "JumpLbl")
            {
                GlobalVars.PopUpArg2 = "L5";
                Arg2PreviewBox.Text = "L5";
                BtnPopupAdd.IsEnabled = true;
            }
        }

        //******************************************* Btn_popupAdd_Clicked ************************************************
        // This function fills the active program line with an instruction accordingly to selected options in popup window.
        private void Btn_popupAdd_Clicked(object sender, RoutedEventArgs e)
        {
            int tmpInt = GlobalVars.prog1ActiveLine;
            byte tmpByte = 0;

            if (GlobalVars.PopUpType == "Do")
            {
                GlobalVars.prog1InstByte[tmpInt, 0] = 2;
                if (GlobalVars.PopUpArg1 == "Do1")
                {
                    tmpByte = 1;  
                }
                else if(GlobalVars.PopUpArg1 == "Do2")
                {
                    tmpByte = 2;
                }
                else if(GlobalVars.PopUpArg1 == "Do3")
                {
                    tmpByte = 3;
                }
                GlobalVars.prog1InstByte[tmpInt, 1] = tmpByte;
                if (GlobalVars.PopUpArg2 == "ON")
                {
                    tmpByte = 1;
                }
                else if (GlobalVars.PopUpArg2 == "OFF")
                {
                    tmpByte = 0;
                }
                GlobalVars.prog1InstByte[tmpInt, 2] = tmpByte;
                GlobalVars.prog1InstString[tmpInt, 0] = GlobalVars.prog1ActiveLine.ToString();
                GlobalVars.prog1InstString[tmpInt, 1] = "DO";
                GlobalVars.prog1InstString[tmpInt, 2] = "->";
                GlobalVars.prog1InstString[tmpInt, 3] = GlobalVars.PopUpArg1;
                GlobalVars.prog1InstString[tmpInt, 4] = "=";
                GlobalVars.prog1InstString[tmpInt, 5] = GlobalVars.PopUpArg2;
                GlobalVars.prog1InstString[tmpInt, 6] = ".";
                GlobalVars.prog1InstString[tmpInt, 7] = ".";
                GlobalVars.prog1InstString[tmpInt, 8] = ".";
                GlobalVars.prog1InstString[tmpInt, 9] = ".";
                GlobalVars.prog1InstString[tmpInt, 10] = ".";
                GlobalVars.prog1InstString[tmpInt, 11] = ".";
                GlobalVars.prog1InstString[tmpInt, 12] = ".";
                GlobalVars.prog1InstString[tmpInt, 13] = ".";
                GlobalVars.prog1InstString[tmpInt, 14] = ".";
                GlobalVars.prog1InstString[tmpInt, 15] = ".";
            }
            else if (GlobalVars.PopUpType == "WaitDi")
            {
                GlobalVars.prog1InstByte[tmpInt, 0] = 3;
                if (GlobalVars.PopUpArg1 == "Di1")
                {
                    tmpByte = 1;
                }
                else if (GlobalVars.PopUpArg1 == "Di2")
                {
                    tmpByte = 2;
                }
                else if (GlobalVars.PopUpArg1 == "Di3")
                {
                    tmpByte = 3;
                }
                GlobalVars.prog1InstByte[tmpInt, 1] = tmpByte;
                if (GlobalVars.PopUpArg2 == "ON")
                {
                    tmpByte = 1;
                }
                else if (GlobalVars.PopUpArg2 == "OFF")
                {
                    tmpByte = 0;
                }
                GlobalVars.prog1InstByte[tmpInt, 2] = tmpByte;
                GlobalVars.prog1InstString[tmpInt, 0] = GlobalVars.prog1ActiveLine.ToString();
                GlobalVars.prog1InstString[tmpInt, 1] = "WAITDI";
                GlobalVars.prog1InstString[tmpInt, 2] = "->";
                GlobalVars.prog1InstString[tmpInt, 3] = GlobalVars.PopUpArg1;
                GlobalVars.prog1InstString[tmpInt, 4] = "=";
                GlobalVars.prog1InstString[tmpInt, 5] = GlobalVars.PopUpArg2;
                GlobalVars.prog1InstString[tmpInt, 6] = ".";
                GlobalVars.prog1InstString[tmpInt, 7] = ".";
                GlobalVars.prog1InstString[tmpInt, 8] = ".";
                GlobalVars.prog1InstString[tmpInt, 9] = ".";
                GlobalVars.prog1InstString[tmpInt, 10] = ".";
                GlobalVars.prog1InstString[tmpInt, 11] = ".";
                GlobalVars.prog1InstString[tmpInt, 12] = ".";
                GlobalVars.prog1InstString[tmpInt, 13] = ".";
                GlobalVars.prog1InstString[tmpInt, 14] = ".";
                GlobalVars.prog1InstString[tmpInt, 15] = ".";
            }
            else if (GlobalVars.PopUpType == "JumpLbl")
            {
                
                if (GlobalVars.PopUpArg1 == "JUMP")
                {
                    GlobalVars.prog1InstByte[tmpInt, 0] = 6;
                }
                else if (GlobalVars.PopUpArg1 == "LABEL")
                {
                    GlobalVars.prog1InstByte[tmpInt, 0] = 7;
                }
                if (GlobalVars.PopUpArg2 == "L1")
                {
                    tmpByte = 1;
                }
                else if (GlobalVars.PopUpArg2 == "L2")
                {
                    tmpByte = 2;
                }
                else if (GlobalVars.PopUpArg2 == "L3")
                {
                    tmpByte = 3;
                }
                else if (GlobalVars.PopUpArg2 == "L4")
                {
                    tmpByte = 4;
                }
                else if (GlobalVars.PopUpArg2 == "L5")
                {
                    tmpByte = 5;
                }
                GlobalVars.prog1InstByte[tmpInt, 1] = tmpByte;
                GlobalVars.prog1InstString[tmpInt, 0] = GlobalVars.prog1ActiveLine.ToString();
                GlobalVars.prog1InstString[tmpInt, 1] = GlobalVars.PopUpArg1;
                GlobalVars.prog1InstString[tmpInt, 2] = "->";
                GlobalVars.prog1InstString[tmpInt, 3] = GlobalVars.PopUpArg2;
                GlobalVars.prog1InstString[tmpInt, 4] = ".";
                GlobalVars.prog1InstString[tmpInt, 5] = ".";
                GlobalVars.prog1InstString[tmpInt, 6] = ".";
                GlobalVars.prog1InstString[tmpInt, 7] = ".";
                GlobalVars.prog1InstString[tmpInt, 8] = ".";
                GlobalVars.prog1InstString[tmpInt, 9] = ".";
                GlobalVars.prog1InstString[tmpInt, 10] = ".";
                GlobalVars.prog1InstString[tmpInt, 11] = ".";
                GlobalVars.prog1InstString[tmpInt, 12] = ".";
                GlobalVars.prog1InstString[tmpInt, 13] = ".";
                GlobalVars.prog1InstString[tmpInt, 14] = ".";
                GlobalVars.prog1InstString[tmpInt, 15] = ".";
            }
            GlobalVars.prog1ActiveLine++;
            ArgPopup.IsOpen = false;
        }

        //******************************************* Btn_popupCancel_Clicked ************************************************
        // This function closes the popup window.
        private void Btn_popupCancel_Clicked(object sender, RoutedEventArgs e)
        {
            ArgPopup.IsOpen = false;
        }

        ///    *********************************************     Background Logic 1    *******************************************************
        ///    // This Background Logic updates data in the "Prog" Page
        public void BGLogic1()
        {
            while (true)
            {
                Dispatcher.Invoke(() => {
                    Prog1Grid.Children.Clear();
                    for (int i = 0; i < 15; i++)
                    {
                        for (int j = 0; j < GlobalVars.prog1InstString.GetLength(1); j++)
                        {
                            if (GlobalVars.prog1InstString[i, j] != null)
                            {
                                TextBlock instrText = new TextBlock();
                                instrText.Text = GlobalVars.prog1InstString[(i + prog1LineDisplay), j];
                                instrText.FontSize = 14;
                                instrText.TextAlignment = TextAlignment.Center;

                                if ((i + prog1LineDisplay) == GlobalVars.prog1ActiveLine)
                                {
                                    if (GlobalVars.ExeLineRequest == true)
                                    {
                                        instrText.Background = new SolidColorBrush(Colors.Yellow);
                                    }
                                    else
                                    {
                                        instrText.Background = new SolidColorBrush(Colors.LightGreen);
                                    }
                                }
                                else
                                {
                                    instrText.Background = new SolidColorBrush(Colors.White);
                                }
                                Grid.SetRow(instrText, i);
                                Grid.SetColumn(instrText, j);

                                Prog1Grid.Children.Add(instrText);
                            }
                        }
                    }

                    if (GlobalVars.prog1ActiveLine > (prog1LineDisplay + 10))
                    {
                        int tempInt = (GlobalVars.prog1ActiveLine - 10);
                        if (tempInt > (GlobalVars.prog1InstString.GetLength(0) - 15))
                        {
                            tempInt = GlobalVars.prog1InstString.GetLength(0) - 15;
                        }
                        prog1LineDisplay = tempInt;
                    }
                    if (GlobalVars.prog1ActiveLine < (prog1LineDisplay))
                    {
                        prog1LineDisplay = GlobalVars.prog1ActiveLine;
                    }

                    Btn1Prog1.IsEnabled = GlobalVars.BtnsMenuIsEn;
                    Btn2Prog1.IsEnabled = GlobalVars.BtnsMenuIsEn;
                    Btn3Prog1.IsEnabled = GlobalVars.BtnsMenuIsEn;
                    Btn4Prog1.IsEnabled = GlobalVars.BtnsMenuIsEn;
                    Btn5Prog1.IsEnabled = GlobalVars.BtnsMenuIsEn;
                    Btn6Prog1.IsEnabled = GlobalVars.BtnsMenuIsEn;
                    Btn7Prog1.IsEnabled = GlobalVars.BtnsMenuIsEn;
                    Btn8Prog1.IsEnabled = GlobalVars.BtnsMenuIsEn;
                    Btn9Prog1.IsEnabled = GlobalVars.BtnsMenuIsEn;
                    Btn10Prog1.IsEnabled = GlobalVars.BtnsMenuIsEn;

                });
                Thread.Sleep(200);
            }
        }

        ///    *********************************************     Background Logic 2    *******************************************************
        ///    // This Background Logic is unused
        public void BGLogic2()
        {
            while (true)
            {
                Thread.Sleep(100);
            }
        }

    }
}