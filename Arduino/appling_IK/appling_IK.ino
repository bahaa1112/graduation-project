#include <Servo.h>

Servo J1, J2, J3, J4, J5;

// إعدادات النعومة والسرعة (مستوحاة من الكود المرفق)
const int SMOOTH_DELAY = 5;  // زمن الانتظار (ميلي ثانية) - رقم أكبر = أبطأ
const int SMOOTH_STEP = 3;   // مقدار الخطوة بالمايكروثانية - رقم أكبر = أسرع

// زاوية السيرفو الحقيقية التي تمثل الصفر الرياضي القادم من ماتلاب
const float SERVO_HOME_OFFSETS[5] = {90.0, 90.0, 90.0, 90.0, 90.0};
const float SERVO_DIRECTIONS[5]   = {1.0,  1.0,  1.0,  1.0,  1.0};

void setup() {
  Serial.begin(9600);
  
  // مهم جداً لتسريع القراءة من الماتلاب ومنع التأخير
  Serial.setTimeout(50); 
  
  // دبابيس المقبض (محرك DC)
  pinMode(4, OUTPUT); // IN1
  pinMode(5, OUTPUT); // IN2
  pinMode(6, OUTPUT); // PWM

  // ربط المحركات بالدبابيس
  J1.attach(8);
  J2.attach(9);
  J3.attach(10);
  J4.attach(11);
  J5.attach(12);

  // إرسال المحركات إلى زوايا الصفر المخصصة لمنع القفز المفاجئ عند الإقلاع
  J1.write(SERVO_HOME_OFFSETS[0]);
  J2.write(SERVO_HOME_OFFSETS[1]);
  J3.write(SERVO_HOME_OFFSETS[2]);
  J4.write(SERVO_HOME_OFFSETS[3]);
  J5.write(SERVO_HOME_OFFSETS[4]);

  Serial.println("✅ Arduino Ready for MATLAB Control with Smooth Motion.");
}

// ==========================================
// 🌟 دالة الحركة الناعمة المدمجة
// ==========================================
void moveSmooth(Servo &motor, int jointIndex, float mathTargetAngle, int stepSize, int speedDelay) {
  
  // 1. تحويل الزاوية الرياضية (من الماتلاب) إلى زاوية فيزيائية حقيقية
  float targetPhysical = SERVO_HOME_OFFSETS[jointIndex] + (SERVO_DIRECTIONS[jointIndex] * mathTargetAngle);
  
  // حماية ميكانيكية لمنع السيرفو من تجاوز حدوده
  if (targetPhysical < 0) targetPhysical = 0;
  if (targetPhysical > 180) targetPhysical = 180;

  // 2. تحويل الزاوية الفيزيائية الهدف إلى مايكروثانية (نبضات دقيقة)
  int targetMicro = map((int)targetPhysical, 0, 180, 544, 2400);

  // 3. قراءة الموضع الحالي مباشرة من المحرك (الميزة المأخوذة من الكود الأول)
  int currentMicro = motor.readMicroseconds();
  if (currentMicro == 0) currentMicro = 1500; // حماية برمجية في حال الخطأ

  // 4. تنفيذ الحركة الناعمة
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

  // التأكيد النهائي للوصول إلى النقطة بدقة
  motor.writeMicroseconds(targetMicro);
}

// ==========================================
// حلقة الاستقبال (من الماتلاب)
// ==========================================
void loop() {
  if (Serial.available() > 0) {
    String dataData = Serial.readStringUntil('\n');
    dataData.trim(); // إزالة المسافات أو رموز السطر الزائدة

    if (dataData.length() > 0) {
      float jointAngles[5];
      int parseCounter = 0;
      int lastIndex = 0;

      // تفكيك النص القادم من الماتلاب (CSV)
      for (int i = 0; i <= dataData.length(); i++) {
        if (i == dataData.length() || dataData.charAt(i) == ',') {
          String part = dataData.substring(lastIndex, i);
          long rawValue = part.toInt(); // استخراج الرقم المضروب بـ 100
          jointAngles[parseCounter] = (float)rawValue / 100.0; // إعادته لرقم بفاصلة عشرية
          
          parseCounter++;
          lastIndex = i + 1;
          if (parseCounter >= 5) break;
        }
      }

      // التنفيذ فقط إذا تم استلام الزوايا الخمس بنجاح
      if (parseCounter == 5) {
        // Serial.println("Angles received perfectly. Executing...");

        // تنفيذ الحركة للمفاصل مع تمرير متغيرات النعومة
        moveSmooth(J1, 0, jointAngles[0], SMOOTH_STEP, SMOOTH_DELAY);
        moveSmooth(J2, 1, jointAngles[1], SMOOTH_STEP, SMOOTH_DELAY);
        moveSmooth(J3, 2, jointAngles[2], SMOOTH_STEP, SMOOTH_DELAY);
        moveSmooth(J4, 3, jointAngles[3], SMOOTH_STEP, SMOOTH_DELAY);
        moveSmooth(J5, 4, jointAngles[4], SMOOTH_STEP, SMOOTH_DELAY);

        Serial.println("Position reached successfully.");
      } else {
        Serial.print("Error: Incomplete packet received. Parts parsed: ");
        Serial.println(parseCounter);
      }
    }
  }
}
