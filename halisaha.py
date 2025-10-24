import tkinter as tk
from tkinter import messagebox
from PIL import Image, ImageTk

class FutbolSahasiUygulamasi:
    def __init__(self, root):
        self.root = root
        self.root.title("Halı Saha Diziliş Uygulaması")
        self.root.geometry("800x600")

        # Arka plan resmi yükleme
        self.saha_image_path = "halisaha.jpg"
        try:
            self.original_image = Image.open(self.saha_image_path)
            self.saha_foto = ImageTk.PhotoImage(self.original_image)
        except FileNotFoundError:
            messagebox.showerror("Hata", f"Resim bulunamadı: {self.saha_image_path}\nLütfen resmi kodun olduğu dizine koyun.")
            root.destroy()
            return

        self.canvas = tk.Canvas(root, width=self.saha_foto.width(), height=self.saha_foto.height())
        self.canvas.pack(fill="both", expand=True)
        self.canvas.create_image(0, 0, image=self.saha_foto, anchor="nw")

        self.oyuncular = []
        self.secili_oyuncu = None

        # Yeni top ekleme için klavye kısayolları
        self.root.bind('<x>', self.oyuncu_ekle_kirmizi)
        self.root.bind('<c>', self.oyuncu_ekle_mavi)

        # Sürükle ve bırak için mouse olayları
        self.canvas.bind("<Button-1>", self.on_press)
        self.canvas.bind("<B1-Motion>", self.on_drag)
        self.canvas.bind("<ButtonRelease-1>", self.on_release)
        self.canvas.bind("<Double-Button-1>", self.on_double_click)

        self.oyuncu_counter = 0

    def oyuncu_ekle(self, x, y, renk, numara=None):
        self.oyuncu_counter += 1
        if numara is None:
            numara = self.oyuncu_counter

        # Top çizimi
        oyuncu_id = self.canvas.create_oval(x - 15, y - 15, x + 15, y + 15, fill=renk, outline="white", width=2)
        # Numara yazımı
        numara_id = self.canvas.create_text(x, y, text=str(numara), fill="white", font=("Arial", 10, "bold"))

        self.oyuncular.append({
            "id": oyuncu_id,
            "numara_id": numara_id,
            "numara": numara,
            "x": x,
            "y": y
        })
        return oyuncu_id, numara_id

    def oyuncu_ekle_kirmizi(self, event):
        x, y = self.root.winfo_pointerx() - self.root.winfo_rootx() - self.canvas.winfo_x(), \
               self.root.winfo_pointery() - self.root.winfo_rooty() - self.canvas.winfo_y()
        self.oyuncu_ekle(x, y, "red")

    def oyuncu_ekle_mavi(self, event):
        x, y = self.root.winfo_pointerx() - self.root.winfo_rootx() - self.canvas.winfo_x(), \
               self.root.winfo_pointery() - self.root.winfo_rooty() - self.canvas.winfo_y()
        self.oyuncu_ekle(x, y, "blue")

    def on_press(self, event):
        for oyuncu_data in self.oyuncular:
            coords = self.canvas.coords(oyuncu_data["id"])
            if coords[0] <= event.x <= coords[2] and coords[1] <= event.y <= coords[3]:
                self.secili_oyuncu = oyuncu_data
                self.start_x = event.x
                self.start_y = event.y
                self.canvas.tag_raise(oyuncu_data["id"])
                self.canvas.tag_raise(oyuncu_data["numara_id"])
                return

    def on_drag(self, event):
        if self.secili_oyuncu:
            dx = event.x - self.start_x
            dy = event.y - self.start_y
            self.canvas.move(self.secili_oyuncu["id"], dx, dy)
            self.canvas.move(self.secili_oyuncu["numara_id"], dx, dy)
            self.secili_oyuncu["x"] += dx
            self.secili_oyuncu["y"] += dy
            self.start_x = event.x
            self.start_y = event.y

    def on_release(self, event):
        self.secili_oyuncu = None

    def on_double_click(self, event):
        for oyuncu_data in self.oyuncular:
            coords = self.canvas.coords(oyuncu_data["id"])
            if coords[0] <= event.x <= coords[2] and coords[1] <= event.y <= coords[3]:
                self.oyuncu_numarasi_duzenle(oyuncu_data)
                return

    def oyuncu_numarasi_duzenle(self, oyuncu_data):
        dialog = tk.Toplevel(self.root)
        dialog.title("Numara Düzenle")
        dialog.geometry("200x100")
        dialog.transient(self.root)
        dialog.grab_set()

        tk.Label(dialog, text="Yeni Numara:").pack(pady=5)
        entry = tk.Entry(dialog)
        entry.insert(0, str(oyuncu_data["numara"]))
        entry.pack(pady=5)
        entry.focus_set()

        def save_number():
            try:
                yeni_numara = int(entry.get())
                self.canvas.itemconfig(oyuncu_data["numara_id"], text=str(yeni_numara))
                oyuncu_data["numara"] = yeni_numara
                dialog.destroy()
            except ValueError:
                messagebox.showerror("Hata", "Lütfen geçerli bir sayı girin.")

        tk.Button(dialog, text="Kaydet", command=save_number).pack(pady=5)
        dialog.wait_window(dialog)

# Ana pencereyi oluştur ve uygulamayı başlat
if __name__ == "__main__":
    root = tk.Tk()
    app = FutbolSahasiUygulamasi(root)
    root.mainloop()