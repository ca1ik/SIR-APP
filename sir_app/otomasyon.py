# -*- coding: utf-8 -*-
import subprocess
import time
import pygetwindow as gw
import sys
import ctypes
from ctypes.wintypes import RECT

def get_work_area():
    """
    Ekranın kullanılabilir çalışma alanını (görev çubuğu hariç) alır.
    Bu, pencerelerin görev çubuğunun altına girmesini engeller ve boşlukları giderir.
    """
    try:
        work_area = RECT()
        # SPI_GETWORKAREA sabiti 48'dir. Görev çubuğu hariç alanı döndürür.
        ctypes.windll.user32.SystemParametersInfoW(48, 0, ctypes.byref(work_area), 0)
        width = work_area.right - work_area.left
        height = work_area.bottom - work_area.top
        return work_area.left, work_area.top, width, height
    except Exception as e:
        print(f"Hata: Çalışma alanı alınamadı: {e}")
        return 0, 0, 0, 0

# --- DEĞİŞTİRİLECEK ALANLAR ---
# Lütfen bu yolların sisteminizde doğru olduğundan emin olun.
vs_code_path = r'C:\Users\user\AppData\Local\Programs\Microsoft VS Code\Code.exe'
github_desktop_path = r'C:\Users\user\AppData\Local\GitHubDesktop\GithubDesktop.exe'
chrome_path = r'C:\Program Files\Google\Chrome\Application\chrome.exe'

# --- UYGULAMA BİLGİLERİ ---
apps_to_open = [
    {'name': 'VS Code', 'path': vs_code_path, 'args': [], 'title_hints': ['Visual Studio Code']},
    {'name': 'GitHub Desktop', 'path': github_desktop_path, 'args': [], 'title_hints': ['GitHub Desktop']},
    {'name': 'Spotify', 'path': 'spotify:', 'args': [], 'title_hints': ['Spotify']},
    {'name': 'Gemini', 'path': chrome_path, 'args': ['https://gemini.google.com/'], 'title_hints': ['Gemini', 'Yeni Sekme']},
]

def open_applications():
    """
    Belirtilen uygulamaları ayrı işlemlerde açar.
    """
    print("Uygulamalar başlatılıyor...")
    for app in apps_to_open:
        try:
            if app['name'] == 'Spotify':
                subprocess.Popen(f'start {app["path"]}', shell=True)
            else:
                command = [app['path']] + app['args']
                subprocess.Popen(command)
            print(f"-> {app['name']} başlatıldı.")
        except FileNotFoundError:
            print(f"HATA: {app['name']} bulunamadı. Lütfen dosya yolunu kontrol edin: {app['path']}")
        except Exception as e:
            print(f"HATA: {app['name']} başlatılırken bir sorun oluştu: {e}")

def organize_windows_dynamically():
    """
    Pencereleri bulur ve bulduğu anda hemen yerleştirir.
    Tüm pencerelerin açılmasını beklemez.
    """
    print("\nPencereler dinamik olarak düzenleniyor...")
    left, top, work_width, work_height = get_work_area()

    if work_width == 0:
        print("Ekran bilgisi alınamadığı için pencere düzenleme atlandı.")
        return

    print(f"Kullanılabilir Çalışma Alanı: {work_width}x{work_height} (Pozisyon: {left},{top})")

    # Boşluk kalmaması için piksel hassasiyetinde hesaplama
    half_width = work_width // 2
    half_height = work_height // 2
    right_width = work_width - half_width   # Kalan pikselleri sağ tarafa ekle
    bottom_height = work_height - half_height # Kalan pikselleri alt tarafa ekle

    # Pencere konumları ve boyutları
    positions_and_sizes = {
        'Gemini':         {'pos': (left, top), 'size': (half_width, half_height)},
        'VS Code':        {'pos': (left + half_width, top), 'size': (right_width, half_height)},
        'GitHub Desktop': {'pos': (left, top + half_height), 'size': (half_width, bottom_height)},
        'Spotify':        {'pos': (left + half_width, top + half_height), 'size': (right_width, bottom_height)},
    }

    arranged_windows = set()
    attempts = 0
    max_attempts = 40  # 40 saniye boyunca pencereleri ara

    print("Uygulama pencereleri aranıyor ve anında yerleştiriliyor...")
    while len(arranged_windows) < len(apps_to_open) and attempts < max_attempts:
        all_windows = gw.getAllWindows()
        for window in all_windows:
            if not window.visible or not window.title.strip():
                continue

            for app in apps_to_open:
                # Eğer bu uygulama henüz düzenlenmediyse kontrol et
                if app['name'] not in arranged_windows:
                    for hint in app['title_hints']:
                        if hint.lower() in window.title.lower():
                            print(f"\n-> Pencere bulundu ve düzenleniyor: {app['name']}")
                            try:
                                geo = positions_and_sizes[app['name']]
                                win = window

                                if win.isMinimized: win.restore()
                                if win.isMaximized: win.restore()
                                time.sleep(0.05) # Pencerenin durumunu güncellemesi için çok kısa bekle

                                win.resizeTo(*geo['size'])
                                win.moveTo(*geo['pos'])
                                print(f"   '{app['name']}' penceresi {geo['pos']} konumuna taşındı, boyutu {geo['size']} olarak ayarlandı.")
                                
                                arranged_windows.add(app['name'])

                            except Exception as e:
                                print(f"   HATA: '{app['name']}' penceresi düzenlenirken bir sorun oluştu: {e}")
                            
                            break # Uygulama bulundu, diğer ipuçlarına bakma
        
        time.sleep(1)
        attempts += 1
        print(f"Arama denemesi {attempts}/{max_attempts}... Düzenlenenler: {len(arranged_windows)}/{len(apps_to_open)}", end='\r')
    
    print("\n")


if __name__ == '__main__':
    print("Otomasyon Başladı...")
    open_applications()
    
    # Sabit bekleme kaldırıldı, organize_windows_dynamically fonksiyonu
    # pencereleri buldukça kendisi halledecek.
    organize_windows_dynamically()
    
    print("\nOtomasyon Tamamlandı.")
    input("Çıkmak için Enter tuşuna basın...")
    sys.stdout.flush()

