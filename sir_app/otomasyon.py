# Bu betik, belirtilen uygulamaları başlatır ve pencereleri düzenler.

import subprocess
import time
import os
import sys
import threading

# pygetwindow kütüphanesi pencere yönetimi için kullanılır.
try:
    import pygetwindow as gw
except ImportError:
    print("pygetwindow kütüphanesi yükleniyor...")
    subprocess.check_call([sys.executable, "-m", "pip", "install", "pygetwindow"])
    import pygetwindow as gw

def run_in_background(target):
    """Bir fonksiyonu ayrı bir iş parçacığında (thread) çalıştırır."""
    thread = threading.Thread(target=target)
    thread.daemon = True
    thread.start()

def get_window_by_title_with_retries(titles, max_retries=10, delay=1):
    """Pencereyi bulana kadar tekrar dener."""
    for i in range(max_retries):
        for title in titles:
            try:
                window = gw.getWindowsWithTitle(title)
                if window:
                    print(f"Pencere bulundu: {window[0].title}")
                    return window[0]
            except Exception as e:
                print(f"Hata oluştu: {e}")
        print(f"Pencere bulunamadı, {i+1}/{max_retries} tekrar deneniyor...")
        time.sleep(delay)
    print(f"Pencere {titles} başlıklarından herhangi biriyle bulunamadı. Lütfen pencere adını kontrol edin.")
    return None

def start_and_position_apps():
    """
    Uygulamaları başlatır ve pencereleri ekranın ızgarasına göre yerleştirir.
    """
    try:
        # Ekran boyutlarını alın
        screen_width = gw.getScreenSize()[0]
        screen_height = gw.getScreenSize()[1]
        half_width = screen_width // 2
        half_height = screen_height // 2

        # Uygulamaları başlat
        # subprocess.Popen() komutu, programları arka planda çalıştırır.
        print("Uygulamalar başlatılıyor...")
        subprocess.Popen(['C:\\Users\\user\\AppData\\Local\\Programs\\Microsoft VS Code\\Code.exe'])
        subprocess.Popen(['C:\\Users\\user\\AppData\\Local\\GitHubDesktop\\GitHubDesktop.exe'])
        subprocess.Popen(['C:\\Users\\user\\AppData\\Local\\Microsoft\\WindowsApps\\Spotify.exe'])
        subprocess.Popen(['msedge', 'https://gemini.google.com/u/1/app?pli=1'])

        # Programların açılması için bekleme süresi
        time.sleep(5)

        # Pencere başlıkları (Türkçe ve İngilizce adlar)
        window_titles = {
            'vs_code': ['Visual Studio Code', 'Visual Studio Code (Yönetici)'],
            'github': ['GitHub Desktop', 'GitHub Desktop (Yönetici)'],
            'spotify': ['Spotify', 'Spotify - Ana Sayfa'],
            'gemini': ['Gemini - Microsoft Edge']
        }

        # Pencereleri bul ve konumlandır
        print("Pencereler konumlandırılıyor...")

        # Sol üstte: Gemini
        gemini_window = get_window_by_title_with_retries(window_titles['gemini'])
        if gemini_window:
            gemini_window.resizeTo(half_width, half_height)
            gemini_window.moveTo(0, 0)

        # Sağ üstte: VS Code
        vs_code_window = get_window_by_title_with_retries(window_titles['vs_code'])
        if vs_code_window:
            vs_code_window.resizeTo(half_width, half_height)
            vs_code_window.moveTo(half_width, 0)

        # Sol altta: Github Desktop
        github_window = get_window_by_title_with_retries(window_titles['github'])
        if github_window:
            github_window.resizeTo(half_width, half_height)
            github_window.moveTo(0, half_height)

        # Sağ altta: Spotify
        spotify_window = get_window_by_title_with_retries(window_titles['spotify'])
        if spotify_window:
            spotify_window.resizeTo(half_width, half_height)
            spotify_window.moveTo(half_width, half_height)

        print("Otomasyon tamamlandı!")

    except Exception as e:
        print(f"Bir hata oluştu: {e}")

if __name__ == '__main__':
    run_in_background(start_and_position_apps)
