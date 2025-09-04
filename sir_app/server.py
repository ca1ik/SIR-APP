# Flask'tan gerekli modülleri içe aktarır
from flask import Flask, jsonify, request
# subprocess, işletim sistemi komutlarını çalıştırmak için kullanılır
import subprocess
# threading, arka plan görevlerini ana programı engellemeden çalıştırmak için kullanılır
import threading
import sys
import os

app = Flask(__name__)

# Arka planda çalışacak bir fonksiyon
def run_otomasyon(video_path):
    """
    Önce videoyu oynatır, ardından otomasyon betiğini başlatır.
    """
    try:
        # Önce videoyu oynat
        # start komutu video oynatıcıyı varsayılan olarak başlatır
        subprocess.Popen(['start', '', video_path], shell=True)
        print(f"Video başlatıldı: {video_path}")
        
        # Ardından otomasyonu başlat
        script_dir = os.path.dirname(os.path.abspath(__file__))
        otomasyon_path = os.path.join(script_dir, "otomasyon.py")
        subprocess.Popen([sys.executable, otomasyon_path])
        print("Otomasyon betiği başlatıldı.")
    except Exception as e:
        print(f"Hata: Otomasyon veya video başlatılırken bir sorun oluştu: {e}")

# '/start_automation' URL'si için bir POST isteği dinler
@app.route('/start_automation', methods=['POST'])
def start_automation():
    """
    İstemciden gelen video yolunu alır ve otomasyonu başlatır.
    """
    data = request.get_json()
    video_path = data.get('video_path')

    if not video_path:
        return jsonify({"error": "Video yolu belirtilmedi."}), 400

    # İsteği alır almaz otomasyonu ayrı bir iş parçacığında çalıştırır.
    thread = threading.Thread(target=run_otomasyon, args=(video_path,))
    thread.start()
    return jsonify({"status": "Otomasyon başlatılıyor..."}), 200

# Ana fonksiyon
if __name__ == '__main__':
    # Flask sunucusunu çalıştırır
    app.run(port=5000)
