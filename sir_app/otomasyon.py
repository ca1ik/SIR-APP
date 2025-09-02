import subprocess
import time
import pygetwindow as gw
import sys

# Dosya yolları
vs_code_path = r'C:\Users\user\AppData\Local\Programs\Microsoft VS Code\Code.exe'
github_desktop_path = r'C:\Users\user\AppData\Local\GitHubDesktop\GithubDesktop.exe'
spotify_command = 'start spotify:'
chrome_path = r'C:\Program Files\Google\Chrome\Application\chrome.exe' # Default path, adjust if needed

# Uygulama adları ve pencere başlıkları
apps_to_open = [
    {'name': 'VS Code', 'path': vs_code_path, 'title_hints': ['Visual Studio Code', 'Visual Studio Code - Insiders']},
    {'name': 'GitHub Desktop', 'path': github_desktop_path, 'title_hints': ['GitHub Desktop']},
    {'name': 'Spotify', 'path': spotify_command, 'title_hints': ['Spotify']},
    {'name': 'Gemini', 'path': chrome_path, 'args': ['https://gemini.google.com/u/1/app?pli=1'], 'title_hints': ['Gemini - Google Chrome', 'Gemini - Brave', 'Gemini - Firefox', 'Yeni Sekme']},
]

def open_applications():
    """
    Belirtilen uygulamaları açar.
    """
    for app in apps_to_open:
        try:
            if app['name'] == 'Spotify':
                # Spotify için özel komut
                subprocess.Popen(f'start {app["path"]}', shell=True)
            elif 'args' in app:
                # Argümanlı uygulamalar için
                command = [app['path']] + app['args']
                subprocess.Popen(command, shell=True)
            else:
                # Diğer uygulamalar
                subprocess.Popen(app['path'])
            print(f"{app['name']} başlatıldı.")
            time.sleep(2) # Uygulamaların açılmasına izin vermek için bekleme
        except FileNotFoundError:
            print(f"Hata: {app['name']} bulunamadı. Lütfen dosya yolunu kontrol edin: {app['path']}")
        except Exception as e:
            print(f"Hata: {app['name']} başlatılırken bir sorun oluştu: {e}")

def organize_windows():
    """
    Açık pencereleri bulur ve ekranı 4 eşit parçaya böler.
    """
    try:
        screen_width = gw.get_monitors()[0].width
        screen_height = gw.get_monitors()[0].height
    except IndexError:
        print("Ekran bilgileri alınamadı. Pencere düzenlemesi atlanıyor.")
        return

    # Ekranı 4 eşit parçaya bölme
    quarter_width = screen_width // 2
    quarter_height = screen_height // 2

    window_positions = {
        'sol_ust': (0, 0, quarter_width, quarter_height),
        'sag_ust': (quarter_width, 0, quarter_width, quarter_height),
        'sol_alt': (0, quarter_height, quarter_width, quarter_height),
        'sag_alt': (quarter_width, quarter_height, quarter_width, quarter_height),
    }

    # Belirtilen pencere başlıklarını bulma ve yerleştirme
    app_windows = {}
    attempts = 0
    max_attempts = 15

    while len(app_windows) < 4 and attempts < max_attempts:
        open_windows = gw.getAllWindows()
        for window in open_windows:
            if window.title.strip() == '':
                continue
            for app in apps_to_open:
                for hint in app['title_hints']:
                    if hint in window.title and app['name'] not in app_windows:
                        app_windows[app['name']] = window
                        print(f"'{app['name']}' penceresi bulundu: {window.title}")
                        break
        time.sleep(1) # Pencerelerin tam olarak yüklenmesi için bekleme
        attempts += 1

    # Pencereleri konumlandırma
    if 'Gemini' in app_windows:
        win = app_windows['Gemini']
        if not win.isActive: win.activate()
        win.resizeTo(window_positions['sol_ust'][2], window_positions['sol_ust'][3])
        win.moveTo(window_positions['sol_ust'][0], window_positions['sol_ust'][1])

    if 'VS Code' in app_windows:
        win = app_windows['VS Code']
        if not win.isActive: win.activate()
        win.resizeTo(window_positions['sag_ust'][2], window_positions['sag_ust'][3])
        win.moveTo(window_positions['sag_ust'][0], window_positions['sag_ust'][1])

    if 'GitHub Desktop' in app_windows:
        win = app_windows['GitHub Desktop']
        if not win.isActive: win.activate()
        win.resizeTo(window_positions['sol_alt'][2], window_positions['sol_alt'][3])
        win.moveTo(window_positions['sol_alt'][0], window_positions['sol_alt'][1])

    if 'Spotify' in app_windows:
        win = app_windows['Spotify']
        if not win.isActive: win.activate()
        win.resizeTo(window_positions['sag_alt'][2], window_positions['sag_alt'][3])
        win.moveTo(window_positions['sag_alt'][0], window_positions['sag_alt'][1])

    print("Pencereler düzenlendi.")

if __name__ == '__main__':
    print("Otomasyon başladı...")
    open_applications()
    time.sleep(5)  # Uygulamaların tamamen açılması için bekleme
    organize_windows()
    print("Otomasyon tamamlandı.")
    sys.stdout.flush()
