import subprocess
import time
import pygetwindow as gw

def main():
    try:
        # Get screen width and height
        ekran = gw.getWindowsWithTitle('')[0].getScreenDimensions()
        genislik = ekran[2]
        yukseklik = ekran[3]
        
        # Calculate target dimensions for each window
        pencere_genislik = genislik // 2
        pencere_yukseklik = yukseklik // 2

        # Start the applications
        uygulamalar = {
            'sol-ust': {
                'komut': ['msedge', 'https://gemini.google.com/u/1/app?pli=1'],
                'baslik': ['Gemini', 'Microsoft Edge']
            },
            'sag-ust': {
                'komut': ['code'],
                'baslik': ['Visual Studio Code']
            },
            'sol-alt': {
                'komut': ['github'],
                'baslik': ['GitHub Desktop']
            },
            'sag-alt': {
                'komut': ['spotify'],
                'baslik': ['Spotify']
            }
        }
        
        print("Uygulamalar başlatılıyor...")
        for konum, bilgi in uygulamalar.items():
            subprocess.Popen(bilgi['komut'])
            time.sleep(2)  # Wait for applications to open

        time.sleep(5) # Wait a bit longer for windows to fully load

        print("Pencereler yerleştiriliyor...")
        # Set window positions
        pencereler_pozisyon = {
            'sol-ust': (0, 0, pencere_genislik, pencere_yukseklik),
            'sag-ust': (pencere_genislik, 0, pencere_genislik, pencere_yukseklik),
            'sol-alt': (0, pencere_yukseklik, pencere_genislik, pencere_yukseklik),
            'sag-alt': (pencere_genislik, pencere_yukseklik, pencere_genislik, pencere_yukseklik)
        }

        # Match and place application windows
        for konum, bilgi in uygulamalar.items():
            for baslik in bilgi['baslik']:
                try:
                    pencere = gw.getWindowsWithTitle(baslik)
                    if pencere:
                        print(f"{baslik} penceresi bulundu. Yerleştiriliyor.")
                        pencere[0].moveTo(pencereler_pozisyon[konum][0], pencereler_pozisyon[konum][1])
                        pencere[0].resizeTo(pencereler_pozisyon[konum][2], pencereler_pozisyon[konum][3])
                        break
                except gw.PyGetWindowException:
                    print(f"Hata: '{baslik}' penceresi bulunamadı. Başlık değişmiş olabilir.")
                except Exception as e:
                    print(f"Pencere yerleştirilirken beklenmeyen bir hata oluştu: {e}")

    except Exception as e:
        print(f"Genel hata: {e}")

if __name__ == "__main__":
    main()
