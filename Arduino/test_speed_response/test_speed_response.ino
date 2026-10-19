#include <VarSpeedServo.h>

VarSpeedServo J1, J2, J3, J4, J5;

// زوايا الصفر الرياضي
const float SERVO_HOME_OFFSETS[5] = {90.0, 90.0, 90.0, 90.0, 90.0};

// سرعة الاختبار (قم بتغييرها بين 10 و 40 لتجد السرعة الأنسب لذراعك)
const int TEST_SPEED =7; 

void setup() {
  Serial.begin(9600);
  
  J1.attach(8);
  J2.attach(9);
  J3.attach(10);
  J4.attach(11);
  J5.attach(12);

  Serial.println("⚙️ Starting VarSpeedServo Smoothness Test...");

  // الذهاب لوضع الصفر ببطء عند التشغيل
  // نضع false لأول 4 مفاصل لتبدأ معاً، ونضع true للأخير ليتزامنوا وينتظر الكود اكتمال حركتهم
  J1.write(SERVO_HOME_OFFSETS[0], TEST_SPEED, false);
  J2.write(SERVO_HOME_OFFSETS[1], TEST_SPEED, false);
  J3.write(SERVO_HOME_OFFSETS[2], TEST_SPEED, false);
  J4.write(SERVO_HOME_OFFSETS[3], TEST_SPEED, false);
  J5.write(SERVO_HOME_OFFSETS[4], TEST_SPEED, true); 
  
  delay(4000); // انتظار للاستقرار
}

void loop() {
  // ==========================================
  // 🔄 روتين الاختبار المتزامن (Simultaneous Movement)
  // ==========================================

  Serial.println("Moving to Target 1 (+ Angles)...");
  // تحريك كل المفاصل معاً بانسجام تام
  J1.write(90 + 45, TEST_SPEED, false);
  J2.write(90 + 30, TEST_SPEED, false); // المفصل الثاني والثالث سيتحركان للزاوية 120
  J3.write(90 + 45, TEST_SPEED, false);
  J4.write(90 + 30, TEST_SPEED, false);
  J5.write(90 + 45, TEST_SPEED, true);  // ننتظر فقط إتمام الحركة
  
  // خلال هذا الانتظار (3 ثوانٍ) راقب المفصل 2 و 3، هل هناك أي اهتزاز (Jitter)؟
  delay(6000); 

  Serial.println("Returning to Home (90 Degrees)...");
  // العودة للوضع الصفري معاً
  J1.write(SERVO_HOME_OFFSETS[0], TEST_SPEED, false);
  J2.write(SERVO_HOME_OFFSETS[1], TEST_SPEED, false);
  J3.write(SERVO_HOME_OFFSETS[2], TEST_SPEED, false);
  J4.write(SERVO_HOME_OFFSETS[3], TEST_SPEED, false);
  J5.write(SERVO_HOME_OFFSETS[4], TEST_SPEED, true);
  
  delay(3000);

  Serial.println("Moving to Target 2 (- Angles)...");
  // تحريك المفاصل للاتجاه المعاكس
  J1.write(90 - 45, TEST_SPEED, false);
  J2.write(90 - 30, TEST_SPEED, false); // المفصل الثاني والثالث سيتحركان للزاوية 60
  J3.write(90 - 45, TEST_SPEED, false);
  J4.write(90 - 30, TEST_SPEED, false);
  J5.write(90 - 45, TEST_SPEED, true);
  
  delay(3000);
}
