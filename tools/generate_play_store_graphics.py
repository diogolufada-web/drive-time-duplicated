"""Gera graficos para a Play Store (1024x500)."""
from __future__ import annotations

import os
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "assets" / "images"
OUT = ROOT / "play-store"
GOLD = (212, 175, 55)
CREAM = (248, 247, 244)
DARK = (22, 22, 22)
DARK2 = (38, 34, 28)


def _font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    candidates = [
        r"C:\Windows\Fonts\segoeuib.ttf" if bold else r"C:\Windows\Fonts\segoeui.ttf",
        r"C:\Windows\Fonts\arialbd.ttf" if bold else r"C:\Windows\Fonts\arial.ttf",
    ]
    for path in candidates:
        if os.path.exists(path):
            return ImageFont.truetype(path, size)
    return ImageFont.load_default()


def _paste_center(base: Image.Image, overlay: Image.Image, cx: int, cy: int) -> None:
    x = cx - overlay.size[0] // 2
    y = cy - overlay.size[1] // 2
    base.paste(overlay, (x, y), overlay)


def _resize_h(img: Image.Image, height: int) -> Image.Image:
    w, h = img.size
    scale = height / h
    return img.resize((int(w * scale), height), Image.LANCZOS)


def _gradient(w: int, h: int, top: tuple[int, int, int], bottom: tuple[int, int, int]) -> Image.Image:
    img = Image.new("RGB", (w, h))
    draw = ImageDraw.Draw(img)
    for y in range(h):
        t = y / max(h - 1, 1)
        color = tuple(int(top[i] + (bottom[i] - top[i]) * t) for i in range(3))
        draw.line([(0, y), (w, y)], fill=color)
    return img


def dark_centered() -> Image.Image:
    bg = _gradient(1024, 500, DARK, DARK2)
    draw = ImageDraw.Draw(bg)
    draw.rectangle([0, 497, 1024, 500], fill=GOLD)

    logo = Image.open(ASSETS / "drive_time_logo_dark.png").convert("RGBA")
    logo = _resize_h(logo, 300)
    _paste_center(bg, logo, 512, 245)
    return bg


def split_layout() -> Image.Image:
    bg = Image.new("RGB", (1024, 500), CREAM)
    draw = ImageDraw.Draw(bg)
    draw.rectangle([0, 0, 400, 500], fill=DARK)
    draw.rectangle([400, 0, 404, 500], fill=GOLD)

    mark = Image.open(ASSETS / "drive_time_mark.png").convert("RGBA")
    mark = _resize_h(mark, 220)
    _paste_center(bg, mark, 200, 250)

    title_font = _font(42, bold=True)
    sub_font = _font(24)
    accent_font = _font(20, bold=True)

    x = 440
    draw.text((x, 130), "DRIVE", fill=(30, 30, 30), font=title_font)
    tw = draw.textlength("DRIVE ", font=title_font)
    draw.text((x + tw, 130), "TIME", fill=GOLD, font=title_font)

    lines = [
        "Turnos e pausas",
        "Histórico e relatórios PDF",
        "Para motoristas TVDE",
    ]
    y = 210
    for line in lines:
        draw.ellipse([x - 4, y + 10, x + 8, y + 22], fill=GOLD)
        draw.text((x + 20, y), line, fill=(70, 70, 70), font=sub_font)
        y += 48

    draw.text((x, 400), "TEMPO  ·  FOCO  ·  RESULTADOS", fill=GOLD, font=accent_font)
    return bg


def light_minimal() -> Image.Image:
    bg = Image.new("RGB", (1024, 500), CREAM)
    draw = ImageDraw.Draw(bg)
    draw.rectangle([80, 80, 944, 420], outline=(*GOLD, 80), width=2)
    draw.rectangle([0, 0, 1024, 6], fill=GOLD)
    draw.rectangle([0, 494, 1024, 500], fill=GOLD)

    logo = Image.open(ASSETS / "drive_time_logo_light.png").convert("RGBA")
    logo = _resize_h(logo, 280)
    _paste_center(bg, logo, 512, 250)
    return bg


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    variants = {
        "feature-graphic-1024x500.png": dark_centered(),
        "feature-graphic-split.png": split_layout(),
        "feature-graphic-light.png": light_minimal(),
    }
    for name, img in variants.items():
        path = OUT / name
        img.save(path, "PNG", optimize=True)
        print(f"Wrote {path}")


if __name__ == "__main__":
    main()
