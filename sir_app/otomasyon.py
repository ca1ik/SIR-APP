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
    Opens the specified applications in separate processes.
    """
    processes = []
    for app in apps_to_open:
        try:
            if app['name'] == 'Spotify':
                proc = subprocess.Popen(f'start {app["path"]}', shell=True)
            elif 'args' in app:
                command = [app['path']] + app['args']
                proc = subprocess.Popen(command, shell=True)
            else:
                proc = subprocess.Popen(app['path'])
            processes.append(proc)
            print(f"{app['name']} starting...")
        except FileNotFoundError:
            print(f"Error: {app['name']} not found. Please check the file path: {app['path']}")
        except Exception as e:
            print(f"Error: An issue occurred while launching {app['name']}: {e}")

def organize_windows():
    """
    Finds open windows and arranges them in a four-quadrant grid.
    """
    try:
        monitors = gw.get_monitors()
        if not monitors:
            print("No monitors found. Window arrangement skipped.")
            return

        main_monitor = monitors[0]
        screen_width = main_monitor.width
        screen_height = main_monitor.height

    except IndexError:
        print("Screen info could not be obtained. Window arrangement skipped.")
        return

    # Split the screen into 4 equal quadrants
    quarter_width = screen_width // 2
    quarter_height = screen_height // 2

    # Define window positions based on the desired layout
    window_positions = {
        'Gemini': (0, 0),                       # Top-Left
        'VS Code': (quarter_width, 0),          # Top-Right
        'GitHub Desktop': (0, quarter_height),  # Bottom-Left
        'Spotify': (quarter_width, quarter_height), # Bottom-Right
    }

    # Wait for the windows to be available
    app_windows = {}
    attempts = 0
    max_attempts = 40 

    while len(app_windows) < 4 and attempts < max_attempts:
        open_windows = gw.getAllWindows()
        for window in open_windows:
            if window.title.strip() == '':
                continue
            for app in apps_to_open:
                if app['name'] not in app_windows:
                    for hint in app['title_hints']:
                        if hint.lower() in window.title.lower():
                            app_windows[app['name']] = window
                            break
        time.sleep(1) # Wait for windows to load completely
        attempts += 1
    
    if len(app_windows) < 4:
        print(f"Warning: Could not find all application windows. Found {len(app_windows)} out of 4.")
        
    # Resize and move the windows to their designated positions
    for app_name, pos in window_positions.items():
        if app_name in app_windows:
            win = app_windows[app_name]
            try:
                # Ensure window is visible and not minimized before resizing
                if win.isMinimized:
                    win.restore()
                # Make sure the window is not maximized
                if win.isMaximized:
                    win.restore()
                
                win.resizeTo(quarter_width, quarter_height)
                win.moveTo(pos[0], pos[1])
            except gw.PyGetWindowException as e:
                print(f"Error arranging window '{app_name}': {e}")
                
    print("Windows arranged.")

if __name__ == '__main__':
    print("Automation started...")
    open_applications()
    time.sleep(15)  # Uygulamaların tamamen açılması için bekleme
    organize_windows()
    print("Automation completed.")
    sys.stdout.flush()
