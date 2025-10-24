#!/usr/bin/env python3
import os
import math
import hashlib
import argparse
import fitz
import torch
from transformers import MarianMTModel, MarianTokenizer

class TranslatorHF:
    def __init__(self, model_name="Helsinki-NLP/opus-mt-en-tr", device=None):
        self.device = device or ("cuda" if torch.cuda.is_available() else "cpu")
        print(f"[INFO] Using device: {self.device}")
        self.tokenizer = MarianTokenizer.from_pretrained(model_name)
        self.model = MarianMTModel.from_pretrained(model_name).to(self.device)
        self.cache = {}

    def translate(self, text):
        if not text.strip():
            return text
        key = hashlib.sha256(text.encode("utf-8")).hexdigest()
        if key in self.cache:
            return self.cache[key]
        batch = self.tokenizer([text], return_tensors="pt", padding=True).to(self.device)
        translated = self.model.generate(**batch)
        output = self.tokenizer.decode(translated[0], skip_special_tokens=True)
        self.cache[key] = output
        return output

def ensure_dir(path):
    if not os.path.exists(path):
        os.makedirs(path, exist_ok=True)

def process_pdf(input_pdf, output_dir, pages_per_chunk=20, target_lang="TR", dpi=150):
    ensure_dir(output_dir)
    doc = fitz.open(input_pdf)
    total_pages = doc.page_count
    chunks = math.ceil(total_pages / pages_per_chunk)
    print(f"Girdi: {total_pages} sayfa -> {chunks} blok ({pages_per_chunk} sayfa/blok)")

    translator = TranslatorHF()
    for chunk_idx in range(chunks):
        start = chunk_idx * pages_per_chunk
        end = min(start + pages_per_chunk, total_pages)
        out_file = os.path.join(output_dir, f"{os.path.splitext(os.path.basename(input_pdf))[0]}_{start+1:04d}-{end:04d}_tr.pdf")
        print(f"\n==> Blok {chunk_idx+1}/{chunks}: sayfalar {start+1}-{end} -> {out_file}")
        new_doc = fitz.open()

        for pno in range(start, end):
            page = doc.load_page(pno)
            rect = page.rect

            # Sayfayı resim olarak arka plan al
            mat = fitz.Matrix(dpi/72, dpi/72)
            pix = page.get_pixmap(matrix=mat, alpha=False)
            img_bytes = pix.tobytes("png")
            newpage = new_doc.new_page(width=rect.width, height=rect.height)
            newpage.insert_image(fitz.Rect(0, 0, rect.width, rect.height), stream=img_bytes)

            # Tüm görünen kelimeleri al
            words = page.get_text("words")  # [(x0, y0, x1, y1, "word", block_no, line_no, word_no)]
            if not words:
                continue
            # Satır bazlı grupla
            lines = {}
            for w in words:
                x0, y0, x1, y1, word, block_no, line_no, word_no = w
                key = (block_no, line_no)
                if key not in lines:
                    lines[key] = {"bbox": [x0, y0, x1, y1], "words": []}
                lines[key]["words"].append(word)
                lines[key]["bbox"][0] = min(lines[key]["bbox"][0], x0)
                lines[key]["bbox"][1] = min(lines[key]["bbox"][1], y0)
                lines[key]["bbox"][2] = max(lines[key]["bbox"][2], x1)
                lines[key]["bbox"][3] = max(lines[key]["bbox"][3], y1)

            # Satır satır çevir ve yaz
            for line in lines.values():
                text_line = " ".join(line["words"])
                try:
                    translated_line = translator.translate(text_line)
                except Exception as e:
                    print(f"  Çeviri hatası: {e}")
                    translated_line = text_line
                x0, y0, x1, y1 = line["bbox"]
                bbox = fitz.Rect(x0, y0, x1, y1)
                fontsize = max(6, min(round((y1 - y0) * 0.9), 28))
                try:
                    newpage.insert_textbox(bbox, translated_line, fontsize=fontsize, fontname="helv", align=0)
                except Exception:
                    try:
                        newpage.insert_text((x0, y0 + fontsize), translated_line, fontsize=fontsize, fontname="helv")
                    except:
                        pass

        try:
            new_doc.save(out_file)
            print(f"  Kaydedildi: {out_file}")
        except Exception as e:
            print(f"  PDF kaydetme hatası: {e}")
        finally:
            new_doc.close()
    doc.close()
    print("Tamamlandı.")

def main():
    parser = argparse.ArgumentParser(description="GPU ile PDF çeviri")
    parser.add_argument("--input", "-i", required=True, help="Girdi PDF")
    parser.add_argument("--outdir", "-o", default="translated_chunks", help="Çıktı dizini")
    parser.add_argument("--pages-per-chunk", "-n", type=int, default=20, help="Blok sayfa sayısı")
    parser.add_argument("--dpi", type=int, default=150, help="Arka plan DPI")
    args = parser.parse_args()
    process_pdf(args.input, args.outdir, pages_per_chunk=args.pages_per_chunk, dpi=args.dpi)

if __name__ == "__main__":
    main()
