import pyaudio
import json
import serial
import time
from vosk import Model, KaldiRecognizer

# ==========================================
# 1. قوائم الأوامر الصوتية (يمكنك إضافة أي جمل هنا بسهولة)
# ==========================================
commands_for_A = ["move to point a", "go to a", "take it to a"]
commands_for_B = ["move to point b", "go to b", "take it to b"]
commands_for_open = ["open", "release", "drop"]
commands_for_close = ["close", "pick", "grab"]

# ==========================================
# 2. إعداد الاتصال مع الأردوينو
# ==========================================
try:
    # الرجاء التأكد من رقم المنفذ لديك
    arduino = serial.Serial('COM9', 9600, timeout=1)
    time.sleep(2)
    print("✅ Connected to Arduino successfully.")
except Exception as e:
    print(f"❌ Failed to connect to Arduino: {e}")
    exit()

# ==========================================
# 3. تحميل نموذج Vosk اللغوي
# ==========================================
print("Loading VOSK model...")
try:
    model = Model("model")
    recognizer = KaldiRecognizer(model, 16000)
except Exception as e:
    print(f"❌ Failed to load model. Ensure the 'model' folder is in the same directory: {e}")
    exit()

# ==========================================
# 4. تشغيل الميكروفون
# ==========================================
p = pyaudio.PyAudio()
stream = p.open(format=pyaudio.paInt16,
                channels=1,
                rate=16000,
                input=True,
                frames_per_buffer=8192)

stream.start_stream()
print("\n🎙️ Listening... Speak a command (e.g., 'move to point a', 'open', 'close'):")

# ==========================================
# 5. حلقة الاستماع المستمر وإرسال الأوامر
# ==========================================
try:
    while True:
        data = stream.read(4096, exception_on_overflow=False)
        
        if recognizer.AcceptWaveform(data):
            result = json.loads(recognizer.Result())
            text = result.get("text", "")
            
            if text:
                print(f"🗣️ You said: {text}")
                
                # فلترة الكلمات وإرسال الإشارة المناسبة للأردوينو
                if any(phrase in text for phrase in commands_for_A):
                    arduino.write(b'A')
                    print("➡️ Command sent: Sequence A")
                    
                elif any(phrase in text for phrase in commands_for_B):
                    arduino.write(b'B')
                    print("➡️ Command sent: Sequence B")
                    
                elif any(phrase in text for phrase in commands_for_open):
                    arduino.write(b'O')
                    print("➡️ Command sent: Open Gripper")
                    
                elif any(phrase in text for phrase in commands_for_close):
                    arduino.write(b'C')
                    print("➡️ Command sent: Close Gripper")
                    
except KeyboardInterrupt:
    print("\n🛑 تم إيقاف البرنامج.")
    stream.stop_stream()
    stream.close()
    p.terminate()