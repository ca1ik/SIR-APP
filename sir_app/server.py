from flask import Flask, jsonify, request
import subprocess
import threading
import os

app = Flask(__name__)

# Otomasyon betiğini arka planda çalıştırmak için fonksiyon
def run_automation_script():
    try:
        # otomasyon_araci.py dosyasını çalıştır
        print("Otomasyon betiği çalıştırılıyor...")
        subprocess.run(['python', 'otomasyon_araci.py'], check=True)
        print("Otomasyon betiği başarıyla tamamlandı.")
    except subprocess.CalledProcessError as e:
        print(f"Hata: Otomasyon betiği çalıştırılırken bir hata oluştu: {e}")
    except FileNotFoundError:
        print("Hata: otomasyon_araci.py dosyası bulunamadı.")
    except Exception as e:
        print(f"Bilinmeyen hata: {e}")

@app.route('/baslat', methods=['POST'])
def baslat_otomasyon():
    # Otomasyonu ayrı bir iş parçacığında (thread) başlat
    # Bu, uygulamanın hemen yanıt vermesini sağlar ve Flutter uygulamasının donmasını engeller.
    thread = threading.Thread(target=run_automation_script)
    thread.start()

    return jsonify({"durum": "başlatıldı", "mesaj": "Otomasyon arka planda çalıştırılıyor."})

if __name__ == '__main__':
    # Geliştirme için kullanılan host ve port
    # production ortamında 0.0.0.0 kullanılması gerekir.
    app.run(host='127.0.0.1', port=5000)
