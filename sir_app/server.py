# Flask'tan gerekli modülleri içe aktarır
from flask import Flask, request
# subprocess, işletim sistemi komutlarını çalıştırmak için kullanılır
import subprocess
# threading, arka plan görevlerini ana programı engellemeden çalıştırmak için kullanılır
import threading
import sys
import os

app = Flask(__name__)

# Arka planda çalışacak bir fonksiyon
def run_otomasyon():
    # otomasyon.py dosyasını çalıştırır.
    # Bu komut, Flutter uygulaması ana iş parçacığını (thread) engellemeden çalışmaya devam eder.
    try:
        # Mevcut betiğin (server.py) dizinini alın
        script_dir = os.path.dirname(os.path.abspath(__file__))
        otomasyon_path = os.path.join(script_dir, "otomasyon.py")
        subprocess.Popen([sys.executable, otomasyon_path])
        print("Otomasyon betiği başlatıldı.")
    except Exception as e:
        print(f"Otomasyon betiğini başlatırken hata oluştu: {e}")

# '/baslat' URL'si için bir POST isteği dinler
@app.route('/baslat', methods=['POST'])
def baslat():
    # İsteği alır almaz otomasyonu ayrı bir iş parçacığında çalıştırır.
    # Böylece Flutter uygulaması donmaz.
    thread = threading.Thread(target=run_otomasyon)
    thread.start()
    return "Otomasyon başlatılıyor...", 200

# Ana fonksiyon
if __name__ == '__main__':
    # Flask sunucusunu çalıştırır
    app.run(port=5000)
