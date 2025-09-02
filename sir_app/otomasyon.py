# -*- coding: utf-8 -*-
import subprocess
import time
import pygetwindow as gw
import sys
import ctypes

def get_screen_resolution():
    """Ekran çözünürlüğünü alır."""
    try:
        user32 = ctypes.windll.user32
        screen_width = user32.GetSystemMetrics(0)
        screen_height = user32.GetSystemMetrics(1)
        return screen_width, screen_height
    except Exception as e:
        print(f"Hata: Ekran çözünürlüğü alınamadı: {e}")
        return None, None

# --- DEĞİŞTİRİLECEK ALANLAR ---
# Lütfen bu yolların sisteminizde doğru olduğundan emin olun.
# Yolunu bulmak için uygulamaya sağ tıklayıp "Dosya konumunu aç" seçeneğini kullanabilirsiniz.
vs_code_path = r'C:\Users\user\AppData\Local\Programs\Microsoft VS Code\Code.exe'
github_desktop_path = r'C:\Users\user\AppData\Local\GitHubDesktop\GithubDesktop.exe'
chrome_path = r'C:\Program Files\Google\Chrome\Application\chrome.exe'

# --- UYGULAMA BİLGİLERİ ---
# Açılacak uygulamalar ve pencere başlıklarındaki ipuçları
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
                # Spotify gibi UWP uygulamaları için 'start' komutu kullanılır
                subprocess.Popen(f'start {app["path"]}', shell=True)
            else:
                # Diğer uygulamalar için tam yol ve argümanlar kullanılır
                command = [app['path']] + app['args']
                subprocess.Popen(command)
            print(f"-> {app['name']} başlatıldı.")
        except FileNotFoundError:
            print(f"HATA: {app['name']} bulunamadı. Lütfen dosya yolunu kontrol edin: {app['path']}")
        except Exception as e:
            print(f"HATA: {app['name']} başlatılırken bir sorun oluştu: {e}")

def organize_windows():
    """
    Açık pencereleri bulur ve ekranı dört çeyreğe bölecek şekilde düzenler.
    """
    print("\nPencereler düzenleniyor...")
    screen_width, screen_height = get_screen_resolution()

    if not screen_width or not screen_height:
        print("Ekran bilgisi alınamadığı için pencere düzenleme atlandı.")
        return

    print(f"Ekran çözünürlüğü: {screen_width}x{screen_height}")

    # Ekranı 4 eşit parçaya böl
    # Pencereler arasında boşluk kalmaması ve tam oturması için
    half_width = screen_width // 2
    half_height = screen_height // 2

    # Pencere konumları: (x, y)
    # 1 -> Sol Üst, 2 -> Sağ Üst, 3 -> Sol Alt, 4 -> Sağ Alt
    window_positions = {
        'Gemini':         (0, 0),
        'VS Code':        (half_width, 0),
        'GitHub Desktop': (0, half_height),
        'Spotify':        (half_width, half_height),
    }

    # Pencerelerin açılmasını beklemek için döngü
    app_windows = {}
    attempts = 0
    max_attempts = 40  # 40 saniye boyunca pencereleri ara

    print("Uygulama pencereleri aranıyor...")
    while len(app_windows) < len(apps_to_open) and attempts < max_attempts:
        all_windows = gw.getAllWindows()
        for window in all_windows:
            if not window.visible or not window.title.strip():
                continue

            for app in apps_to_open:
                if app['name'] not in app_windows:  # Henüz bulunmamış bir pencere mi?
                    for hint in app['title_hints']:
                        if hint.lower() in window.title.lower():
                            print(f"-> Pencere bulundu: {app['name']} ('{window.title}')")
                            app_windows[app['name']] = window
                            break # İpucu bulundu, diğer ipuçlarına bakma
        
        time.sleep(1)
        attempts += 1
        print(f"Arama denemesi {attempts}/{max_attempts}... Bulunanlar: {list(app_windows.keys())}", end='\r')

    print("\n") # Satır başı yap

    if len(app_windows) < len(apps_to_open):
        print(f"UYARI: Tüm uygulama pencereleri bulunamadı. Bulunan {len(app_windows)}/{len(apps_to_open)} pencere düzenlenecek.")

    # Pencereleri yeniden boyutlandır ve taşı
    for app_name, pos in window_positions.items():
        if app_name in app_windows:
            win = app_windows[app_name]
            try:
                # Pencereyi yeniden boyutlandırmadan önce normal durumuna getir
                if win.isMinimized:
                    win.restore()
                if win.isMaximized:
                    win.restore()
                
                time.sleep(0.1) # Pencerenin durumunu güncellemesi için kısa bir bekleme

                # Pencereyi istenen boyuta ve konuma getir
                win.resizeTo(half_width, half_height)
                win.moveTo(pos[0], pos[1])
                print(f"-> '{app_name}' penceresi {pos} konumuna taşındı ve boyutlandırıldı.")

            except gw.PyGetWindowException as e:
                print(f"HATA: '{app_name}' penceresi düzenlenirken bir sorun oluştu: {e}")
        else:
            print(f"UYARI: '{app_name}' penceresi bulunamadığı için atlandı.")


if __name__ == '__main__':
    print("Otomasyon Başladı...")
    open_applications()
    
    # Uygulamaların açılmasına ve pencerelerin oluşmasına zaman tanımak için bekle
    print("\nUygulamaların tamamen açılması için 10 saniye bekleniyor...")
    time.sleep(10)
    
    organize_windows()
    
    print("\nOtomasyon Tamamlandı.")
    # Konsol penceresinin hemen kapanmasını engellemek için
    input("Çıkmak için Enter tuşuna basın...")
    sys.stdout.flush()
