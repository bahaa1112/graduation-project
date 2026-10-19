//    DIY Robotic
//    Educative Robotic Cell - Arduino V1.0
//
//    To use with DIY Robotic Educative Robotic Cell Software V1.0
//    2020-04-22

#include <Servo.h>
#include <SoftwareSerial.h>
//*******************************************  Servo Declaration   *******************************************//

Servo J1servo;
Servo J2servo;
Servo J3servo;
Servo J4servo;
Servo J5servo;
Servo J6servo;

//*******************************************  Arduino Pinout   *******************************************//

//const int LedPin = 13;  // temporaire

const int  Di1_Pin = 2;
const int  J1_PWM_Pin = 3;
const int  Di2_Pin = 4;
const int  J2_PWM_Pin = 5;
const int  J3_PWM_Pin = 6;
const int  Di3_Pin = 7;
const int  Do1_Pin = 8;
const int  J4_PWM_Pin = 9;
const int  J5_PWM_Pin = 10;
const int  J6_PWM_Pin = 11;
const int  Do2_Pin = 12;
const int  Do3_Pin = 13;
const int  Led2_Pin = A0;

//*******************************************  Communication Data Arrays   *******************************************//
byte Data_to_be_sent[15];
byte Data_to_be_received[15];
byte headFinder = 0;
//*******************************************  Init Values   *******************************************//

int tmpInt = 1500;

int J1valDeg = 90;
int J2valDeg = 90;
int J3valDeg = 90;
int J4valDeg = 90;
int J5valDeg = 90;
int J6valDeg = 90;

int J1valus = 1500;
int J2valus = 1500;
int J3valus = 1500;
int J4valus = 1500;
int J5valus = 1500;
int J6valus = 1500;

int J1desDeg = 90;
int J2desDeg = 90;
int J3desDeg = 90;
int J4desDeg = 90;
int J5desDeg = 90;
int J6desDeg = 90;

int Do1des = 0;
int Do2des = 0;
int Do3des = 0;

int Di1des = 0;
int Di2des = 0;
int Di3des = 0;

int Di1Bool = LOW;
int Di2Bool = LOW;
int Di3Bool = LOW;

int Di1State = 0;
int Di2State = 0;
int Di3State = 0;

int Do1State = 0;
int Do2State = 0;
int Do3State = 0;

int led2State = LOW;

int robotSpeed = 50;
int updatePWMDelay = 10;

//*******************************************  Timers Values   *******************************************//

unsigned long currentMillis = 0;

unsigned long previousMillis1 = 0;        // will store last time Send Data
unsigned long previousMillis2 = 0;        // will store last time Update Servo PWM
unsigned long previousMillis3 = 0;        // will store last time Read Di
unsigned long previousMillis4 = 0;        // will store last time Write Do
unsigned long previousMillis5 = 0;        // will store last time Toggle LED2

const long interval1 = 5;             // interval at which to Send Data (milliseconds)
const long interval2 = 5;             // interval at which to Update Servo PWM (milliseconds)
const long interval3 = 200;             // interval at which to Read Di (milliseconds)
const long interval4 = 200;             // interval at which to Write Do (milliseconds)
const long interval5 = 1000;            // interval at which to Toggle LED2


void setup()
{
  //*******************************************  Arduino PinMode Setup   *******************************************//
  pinMode(Led2_Pin, OUTPUT);
  pinMode(Do1_Pin, OUTPUT);
  pinMode(Do2_Pin, OUTPUT);
  pinMode(Do3_Pin, OUTPUT);

  pinMode(Di1_Pin, INPUT);
  pinMode(Di2_Pin, INPUT);
  pinMode(Di3_Pin, INPUT);

  J1servo.attach(J1_PWM_Pin);
  J2servo.attach(J2_PWM_Pin);
  J3servo.attach(J3_PWM_Pin);
  J4servo.attach(J4_PWM_Pin);
  J5servo.attach(J5_PWM_Pin);
  J6servo.attach(J6_PWM_Pin);


  //*******************************************  Reset each communication values   *******************************************//
  Data_to_be_sent[0] = 253;        //head
  Data_to_be_sent[1] = 90;       //J1
  Data_to_be_sent[2] = 90;       //J2
  Data_to_be_sent[3] = 90;       //J3
  Data_to_be_sent[4] = 90;       //J4
  Data_to_be_sent[5] = 90;       //J5
  Data_to_be_sent[6] = 90;       //J6
  Data_to_be_sent[7] = 0;        //Di1
  Data_to_be_sent[8] = 0;        //Di2
  Data_to_be_sent[9] = 0;        //Di3
  Data_to_be_sent[10] = 0;       //Do1
  Data_to_be_sent[11] = 0;       //Do2
  Data_to_be_sent[12] = 0;       //Do3
  Data_to_be_sent[13] = 0;       //robotSpeed
  Data_to_be_sent[14] = 254;       //tail

  Data_to_be_received[0] = 253;        //head
  Data_to_be_received[1] = 90;       //J1
  Data_to_be_received[2] = 90;       //J2
  Data_to_be_received[3] = 90;       //J3
  Data_to_be_received[4] = 90;       //J4
  Data_to_be_received[5] = 90;       //J5
  Data_to_be_received[6] = 90;       //J6
  Data_to_be_received[7] = 0;        //Di1
  Data_to_be_received[8] = 0;        //Di2
  Data_to_be_received[9] = 0;        //Di3
  Data_to_be_received[10] = 0;       //Do1
  Data_to_be_received[11] = 0;       //Do2
  Data_to_be_received[12] = 0;       //Do3
  Data_to_be_received[13] = 0;       //robotSpeed
  Data_to_be_received[14] = 254;       //tail

  Serial.begin(9600);
  
}

void loop()
{



  // Serial.println("Test");
  if (Serial.available() > 0)
  {
    headFinder = Serial.read();
    if (headFinder == 253) {

      Serial.readBytes(Data_to_be_received, 14);


      if (Data_to_be_received[13] == 254)
      {

        J1desDeg = constrain(Data_to_be_received[0], 0, 180);
        J2desDeg = constrain(Data_to_be_received[1], 0, 180);
        J3desDeg = constrain(Data_to_be_received[2], 0, 180);
        J4desDeg = constrain(Data_to_be_received[3], 0, 180);
        J5desDeg = constrain(Data_to_be_received[4], 0, 180);
        J6desDeg = constrain(Data_to_be_received[5], 0, 180);

        //J1desus = map(J1desDeg, 0, 180, 600, 2400);

        Do1des = Data_to_be_received[9];
        Do2des = Data_to_be_received[10];
        Do3des = Data_to_be_received[11];
        robotSpeed = constrain(Data_to_be_received[12], 0, 100);
        updatePWMDelay = 115 - robotSpeed;

      }
      else
      {  }


      //memset(Data_to_be_received,0,sizeof(14));
    }
  }



  currentMillis = millis();
  //*******************************************  Send Data Routine   *******************************************//

  if (currentMillis - previousMillis1 >= interval1) {

    Data_to_be_sent[0] = 253;
    Data_to_be_sent[1] = J1valDeg;                    //J1
    Data_to_be_sent[2] = J2valDeg;                    //J2
    Data_to_be_sent[3] = J3valDeg;                    //J3
    Data_to_be_sent[4] = J4valDeg;                    //J4
    Data_to_be_sent[5] = J5valDeg;                    //J5
    Data_to_be_sent[6] = J6valDeg;                    //J6
    Data_to_be_sent[7] = Di1State;                    //Di1
    Data_to_be_sent[8] = Di2State;                    //Di2
    Data_to_be_sent[9] = Di3State;                    //Di3
    Data_to_be_sent[10] = Do1State;                   //Do1
    Data_to_be_sent[11] = Do2State;                   //Do2
    Data_to_be_sent[12] = Do3State;                   //Do3
    Data_to_be_sent[13] = robotSpeed;                 //robotSpeed
    Data_to_be_sent[14] = 254;

    Serial.write(Data_to_be_sent, 15);
    //memset(Data_to_be_sent,0,sizeof(14));
    currentMillis = millis();
    previousMillis1 = currentMillis;
  }


  currentMillis = millis();
  //*******************************************  Update PWM Routine   *******************************************//

  if (currentMillis - previousMillis2 >= updatePWMDelay) {


    if (J1valDeg < J1desDeg)
    {
      J1valDeg++;
    }
    else if (J1valDeg > J1desDeg)
    {
      J1valDeg--;
    }
    if (J2valDeg < J2desDeg)
    {
      J2valDeg++;
    }
    else if (J2valDeg > J2desDeg)
    {
      J2valDeg--;
    }
    if (J3valDeg < J3desDeg)
    {
      J3valDeg++;
    }
    else if (J3valDeg > J3desDeg)
    {
      J3valDeg--;
    }
    if (J4valDeg < J4desDeg)
    {
      J4valDeg++;
    }
    else if (J4valDeg > J4desDeg)
    {
      J4valDeg--;
    }
    if (J5valDeg < J5desDeg)
    {
      J5valDeg++;
    }
    else if (J5valDeg > J5desDeg)
    {
      J5valDeg--;
    }
    if (J6valDeg < J6desDeg)
    {
      J6valDeg++;
    }
    else if (J6valDeg > J6desDeg)
    {
      J6valDeg--;
    }


    J1valus = map(J1valDeg, 0, 180, 600, 2400);
    J2valus = map(J2valDeg, 0, 180, 600, 2400);
    J3valus = map(J3valDeg, 0, 180, 600, 2400);
    J4valus = map(J4valDeg, 0, 180, 600, 2400);
    J5valus = map(J5valDeg, 0, 180, 600, 2400);
    J6valus = map(J6valDeg, 0, 180, 600, 2400);

    J1servo.writeMicroseconds(J1valus);
    J2servo.writeMicroseconds(J2valus);
    J3servo.writeMicroseconds(J3valus);
    J4servo.writeMicroseconds(J4valus);
    J5servo.writeMicroseconds(J5valus);
    J6servo.writeMicroseconds(J6valus);

    currentMillis = millis();
    previousMillis2 = currentMillis;
  }

    currentMillis = millis();

  //*******************************************  Read Di   *******************************************//

  if (currentMillis - previousMillis3 >= interval3) {

   Di1Bool = digitalRead(Di1_Pin);
   if(Di1Bool == HIGH)
   {
    Di1State = 1;
   }
   else
   {
    Di1State = 0;
   }

   Di2Bool = digitalRead(Di2_Pin);
   if(Di2Bool == HIGH)
   {
    Di2State = 1;
   }
   else
   {
    Di2State = 0;
   }

   Di3Bool = digitalRead(Di3_Pin);
   if(Di3Bool == HIGH)
   {
    Di3State = 1;
   }
   else
   {
    Di3State = 0;
   }

    currentMillis = millis();
    previousMillis3 = currentMillis;
  }

      currentMillis = millis();

  //*******************************************  Write Do   *******************************************//

  if (currentMillis - previousMillis4 >= interval4) {

   if(Do1des == 1)
   {
    Do1State = 1;
    digitalWrite(Do1_Pin, HIGH);
   }
   else
   {
    Do1State = 0;
    digitalWrite(Do1_Pin, LOW);
   }

   if(Do2des == 1)
   {
    Do2State = 1;
    digitalWrite(Do2_Pin, HIGH);
   }
   else
   {
    Do2State = 0;
    digitalWrite(Do2_Pin, LOW);
   }

   if(Do3des == 1)
   {
    Do3State = 1;
    digitalWrite(Do3_Pin, HIGH);
   }
   else
   {
    Do3State = 0;
    digitalWrite(Do3_Pin, LOW);
   }

    currentMillis = millis();
    previousMillis4 = currentMillis;
  }

  currentMillis = millis();

  //*******************************************  Toggle LED2   *******************************************//

  if (currentMillis - previousMillis5 >= interval5) {

    if (led2State == LOW) {
      led2State = HIGH;
    } else {
      led2State = LOW;
    }
    digitalWrite(Led2_Pin, led2State);   // turn the LED on (HIGH is the voltage level)

    currentMillis = millis();
    previousMillis5 = currentMillis;
  }



}
