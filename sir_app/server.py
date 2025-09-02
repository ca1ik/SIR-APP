# Flask'tan gerekli modülleri içe aktarır
from flask import Flask, request, jsonify
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
    try:
        script_dir = os.path.dirname(os.path.abspath(__file__))
        otomasyon_path = os.path.join(script_dir, "otomasyon.py")
        subprocess.Popen([sys.executable, otomasyon_path])
        print("Otomasyon betiği başlatıldı.")
    except Exception as e:
        print(f"Otomasyon betiğini başlatırken hata oluştu: {e}")

# Arka planda müzik çalma fonksiyonu
def run_music(music_file):
    try:
        script_dir = os.path.dirname(os.path.abspath(__file__))
        music_path = os.path.join(script_dir, music_file)
        # Windows'ta ses dosyasını başlatmak için `start` komutunu kullanın.
        subprocess.Popen(['start', music_path], shell=True)
        print(f"{music_file} dosyası başlatıldı.")
    except Exception as e:
        print(f"Müzik dosyasını başlatırken hata oluştu: {e}")

# '/baslat' URL'si için bir POST isteği dinler
@app.route('/baslat', methods=['POST'])
def baslat():
    # İsteği alır almaz otomasyonu ayrı bir iş parçacığında çalıştırır.
    thread = threading.Thread(target=run_otomasyon)
    thread.start()
    return jsonify({"status": "Otomasyon başlatılıyor..."}), 200

# '/play_music/<language>' URL'si için bir POST isteği dinler
@app.route('/play_music/<language>', methods=['POST'])
def play_music(language):
    if language == 'tr':
        music_file = 'wakeuptr.mp3'
    else:
        music_file = 'wakeup.mp3'
    
    # Müziği ayrı bir iş parçacığında çalıştırır
    thread = threading.Thread(target=run_music, args=(music_file,))
    thread.start()
    
    return jsonify({"status": f"{music_file} çalınıyor..."}), 200

# Ana fonksiyon
if __name__ == '__main__':
    # Flask sunucusunu çalıştırır
    app.run(port=5000)
