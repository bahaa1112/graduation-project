#include <Servo.h>

// تعريف محركات السيرفو للذراع
Servo J1, J2, J3, J4, J5;

// تعريف دبابيس التحكم بمحرك المقبض (DC Motor) عبر درايفر المحركات
#define IN1 4
#define IN2 5
#define PWM 6

// متغير تتبع حالة المقبض برمجياً (true = مفتوح ، false = مغلق)
bool isOpen = true; 

// الزمن اللازم لفتح أو إغلاق المقبض بالكامل بالميلي ثانية
const int GRIPPER_TIME = 9000; 

// سرعة محرك المقبض (الحد الأقصى المسموح به 255)
const int GRIPPER_SPEED = 255;

// ==========================================
// دوال التحكم بمحرك التيار المستمر (DC Motor)
// ==========================================

void moveForward(int speed) {
  digitalWrite(IN1, HIGH);
  digitalWrite(IN2, LOW);
  analogWrite(PWM, speed);
}

void moveBackward(int speed) {
  digitalWrite(IN1, LOW);
  digitalWrite(IN2, HIGH);
  analogWrite(PWM, speed);
}

void stopMotor() {
  digitalWrite(IN1, LOW);
  digitalWrite(IN2, LOW);
  analogWrite(PWM, 0);
}

// ==========================================
// 🌟 دالة الحركة الناعمة المطورة (مرونة أعلى بالسرعة)
// ==========================================
// stepSize: مقدار القفزة بالمايكروثانية (رقم أكبر = أسرع)
// speedDelay: زمن الانتظار بالملي ثانية (رقم أكبر = أبطأ وأنعم)

void moveSmooth(Servo &motor, int targetAngle, int stepSize, int speedDelay) {
  // قراءة العرض الدقيق للنبضة الحالية بدلاً من الدرجات التقريبية
  int currentMicro = motor.readMicroseconds();
  if (currentMicro == 0) currentMicro = 1500; // حماية في حال لم يتم تهيئة المحرك

  int targetMicro = map(targetAngle, 0, 180, 544, 2400);

  // إذا كان المحرك قريباً جداً من الهدف، اذهب مباشرة واخرج
  if (abs(currentMicro - targetMicro) <= stepSize) {
    motor.writeMicroseconds(targetMicro);
    return;
  }

  if (currentMicro < targetMicro) {
    for (int pos = currentMicro; pos <= targetMicro; pos += stepSize) {
      motor.writeMicroseconds(pos);
      delay(speedDelay);
    }
  } else {
    for (int pos = currentMicro; pos >= targetMicro; pos -= stepSize) {
      motor.writeMicroseconds(pos);
      delay(speedDelay);
    }
  }

  // التأكيد النهائي للوصول إلى النقطة الدقيقة
  motor.writeMicroseconds(targetMicro);
}

// ==========================================
// دالة إعداد النظام (تنفذ مرة واحدة عند التشغيل)
// ==========================================

void setup() {
  Serial.begin(9600);

  pinMode(IN1, OUTPUT);
  pinMode(IN2, OUTPUT);
  pinMode(PWM, OUTPUT);

 

  J1.attach(8);
  J2.attach(9);
  J3.attach(10);
  J4.attach(11);
  J5.attach(12);

  isOpen = true; 
  
  Serial.println("✅ System Ready (Assuming Gripper is OPEN).");
}

// ==========================================
// الحلقة اللانهائية (تستقبل الأوامر وتنفذ الحركات)
// ==========================================

void loop() {

  if (Serial.available() > 0) {
    char command = Serial.read();

    if (command == '\n' || command == '\r') {
      return;
    }

    switch (command) {

      case 'A':
        if (!isOpen) {
          Serial.println("📂 Preparing for A: Opening gripper first...");
          moveBackward(GRIPPER_SPEED);
          delay(GRIPPER_TIME);
          stopMotor();
          isOpen = true; 
        }

        Serial.println("🚀 Moving to Hover Position (A)...");
        // مثال للتحكم بالسرعة: خطوة 5 وتأخير 15 لحركة انسيابية ومتوسطة السرعة
        moveSmooth(J1, 90 + (50), 5, 3);
        moveSmooth(J2, 90 + (-20), 3, 15);
        moveSmooth(J3, 90 + (0),   3, 15);
        moveSmooth(J4, 90 + (0), 3, 15);
        moveSmooth(J5, 90 + (60), 3, 15);

        delay(1000);

        Serial.println("⬇️ Descending to Target...");
        // النزول ببطء وحذر شديد (خطوة 3 وتأخير 20)
        moveSmooth(J1, 90 + (50), 5, 3);
        moveSmooth(J3, 90 + (20), 3, 20);
        moveSmooth(J4, 90 + (0), 3, 20);
        moveSmooth(J5, 90 + (60), 3, 20);
        moveSmooth(J2, 90 + (-45), 3, 20);
        
        delay(1000);

        Serial.println("🔒 Action A: Gripping object...");
        moveForward(GRIPPER_SPEED);
        delay(GRIPPER_TIME); 
        stopMotor();
        isOpen = false; 

        Serial.println("🚁 Moving to Drop Hover Position...");
        // الرفع بسرعة أكبر قليلاً بعد الالتقاط (خطوة 7 وتأخير 10)
        moveSmooth(J2, 90 + (0), 2,20);
        moveSmooth(J1, 90 + (-80), 5,3);
        moveSmooth(J3, 90 + (0),2, 20);
        moveSmooth(J4, 90 + (0), 2, 20);
        moveSmooth(J5, 90 + (60), 2, 20);

        delay(1000);
        
        Serial.println("⬇️ Descending to Drop Point...");
        moveSmooth(J1, 90 + (-80), 5, 3);
        moveSmooth(J3, 90 + (20), 3, 15);
        moveSmooth(J4, 90 + (0), 3, 15);
        moveSmooth(J5, 90 + (60), 3, 15);
        moveSmooth(J2, 90 + (-45), 3, 15);

        Serial.println("📂 Action A: Releasing object...");
        moveBackward(GRIPPER_SPEED);
        delay(GRIPPER_TIME);
        stopMotor();
        isOpen = true; 

        delay(1000);
        
        Serial.println("🏠 Returning to Home...");
        moveSmooth(J2, 90 + (0), 2, 20);
        moveSmooth(J1, 90 + (0), 5, 3);
        moveSmooth(J3, 90 + (0), 3, 15);
        moveSmooth(J4, 90 + (0), 3, 15);
        moveSmooth(J5, 90 + (0), 3, 15);
        break;

      case 'B':
        if (!isOpen) {
          Serial.println("📂 Preparing for B: Opening gripper first...");
          moveBackward(GRIPPER_SPEED);
          delay(GRIPPER_TIME);
          stopMotor();
          isOpen = true; 
        }

        // تحريك أسرع للوصول لنقطة التحليق B
        moveSmooth(J1, 90 + (30), 3, 10);
        moveSmooth(J2, 90 + (-20), 3, 10);
        moveSmooth(J3, 90 + (30), 3, 10);
        moveSmooth(J4, 90 + (0), 3, 10);
        moveSmooth(J5, 90 + (60), 3, 10);
        
        delay(1000);

        // نزول بطيء
        moveSmooth(J1, 90 + (30), 3, 15);
        moveSmooth(J3, 90 + (50), 3, 15);
        moveSmooth(J4, 90 + (0), 3, 15);
        moveSmooth(J2, 90 + (-63), 3, 15);
        moveSmooth(J5, 90 + (65), 3, 15);
        delay(1000);

        Serial.println("🔒 Action B: Gripping object...");
        moveForward(GRIPPER_SPEED);
        delay(GRIPPER_TIME);
        stopMotor();
        isOpen = false; 

        // تحليق بعد الالتقاط
        moveSmooth(J2, 90 + (0), 3, 12);
        moveSmooth(J3, 90 + (0), 3, 12);
        moveSmooth(J1, 90 + (-80), 3, 12);
        moveSmooth(J4, 90 + (0), 3, 12);
        moveSmooth(J5, 90 + (60), 3, 12);

        delay(1000);
        
        // نزول للإسقاط
        moveSmooth(J1, 90 + (-80), 3, 15);
        moveSmooth(J3, 90 + (20), 3, 15);
        moveSmooth(J4, 90 + (0), 3, 15);
        moveSmooth(J5, 90 + (60), 3, 15);
        moveSmooth(J2, 90 + (-45), 3, 15);

        Serial.println("📂 Action B: Releasing object...");
        moveBackward(GRIPPER_SPEED);
        delay(GRIPPER_TIME);
        stopMotor();
        isOpen = true; 

        delay(1000);
        
        // العودة
        moveSmooth(J2, 90 + (0), 3, 15);
        moveSmooth(J1, 90 + (0), 3, 15);
        moveSmooth(J3, 90 + (0), 3, 15);
        moveSmooth(J4, 90 + (0), 3, 15);
        moveSmooth(J5, 90 + (0), 3, 15);
        break;

      case 'O': 
        if (!isOpen) { 
          Serial.println("📂 Opening Gripper (DC Motor)...");
          moveBackward(GRIPPER_SPEED); 
          delay(GRIPPER_TIME);         
          stopMotor();                 
          isOpen = true; 
        } else {
          Serial.println("⚠️ Gripper is already open.");
        }
        break;

      case 'C': 
        if (isOpen) { 
          Serial.println("🔒 Closing Gripper (DC Motor)...");
          moveForward(GRIPPER_SPEED); 
          delay(GRIPPER_TIME);        
          stopMotor();                
          isOpen = false; 
        } else {
          Serial.println("⚠️ Gripper is already closed.");
        }
        break;
    }
  }
}
