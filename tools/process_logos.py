"""
Processa os 4 logos enviados pelo utilizador:
- remove fundo preto (=> alpha = 0)
- gera duas variantes para light/dark (cor da palavra DRIVE)
- preserva intactos os pixels dourados (incluindo highlights e shadows)

Variants produzidas (em assets/images/):
  drive_time_logo_dark.png        # logo completo + tagline, DRIVE branco  (login)
  drive_time_logo_light.png       # logo completo + tagline, DRIVE preto   (login)
  drive_time_text_dark.png        # "DRIVE TIME" so texto, DRIVE branco    (homepage / outras)
  drive_time_text_light.png       # "DRIVE TIME" so texto, DRIVE preto     (homepage / outras)
  drive_time_mark.png             # so o simbolo DT dourado (ambos modos)

Cada variante e composta com fundo dark/light para preview rapido
(tools/_logo_preview_*.png).
"""

from pathlib import Path

from PIL import Image

SRC_DIR = Path(r"C:\Users\Diogo Terrivel\.cursor\projects\c-Users-Diogo-Terrivel-Desktop-drive-time-duplicated\assets")
OUT_DIR = Path(r"C:\Users\Diogo Terrivel\Desktop\drive-time-duplicated\assets\images")
PREVIEW_DIR = Path(r"C:\Users\Diogo Terrivel\Desktop\drive-time-duplicated\tools")
OUT_DIR.mkdir(parents=True, exist_ok=True)
PREVIEW_DIR.mkdir(parents=True, exist_ok=True)

FULL_LOGO = SRC_DIR / "c__Users_Diogo_Terrivel_AppData_Roaming_Cursor_User_workspaceStorage_empty-window_images_ChatGPT_Image_25_05_2026__23_06_47-dbe574ab-823f-48b6-973c-7d7c7557f9ae.png"
TEXT_WHITE = SRC_DIR / "c__Users_Diogo_Terrivel_AppData_Roaming_Cursor_User_workspaceStorage_empty-window_images_ChatGPT_Image_25_05_2026__23_18_32-7f654d7b-a91a-49d5-bbbd-6293e3132ba3.png"
TEXT_GREY = SRC_DIR / "c__Users_Diogo_Terrivel_AppData_Roaming_Cursor_User_workspaceStorage_empty-window_images_ChatGPT_Image_25_05_2026__23_25_16-5fe9fa5d-ba2b-41fc-a445-c0f6eaab99e2.png"
MARK_ONLY = SRC_DIR / "c__Users_Diogo_Terrivel_AppData_Roaming_Cursor_User_workspaceStorage_empty-window_images_ChatGPT_Image_25_05_2026__23_17_59-dd5c2722-cd62-4683-a7b5-14bd1bcd5246.png"

DARK_BG = (5, 5, 5, 255)
LIGHT_BG = (248, 250, 252, 255)

# ---------------------------------------------------------------------------
# helpers
# ---------------------------------------------------------------------------

def is_gold(r: int, g: int, b: int) -> bool:
    """Pixel com tonalidade dourada (gama larga, apanha highlights e shadows).
    Criterio: nao demasiado preto, NAO neutro/cinza, mais quente que frio.
    """
    if r + g + b < 35:
        return False  # quase puro preto -> fundo
    # neutro/cinza: R, G, B muito proximos
    if max(r, g, b) - min(r, g, b) < 18:
        return False
    # quente: vermelho/verde dominam sobre o azul
    return r >= b + 18 and g >= b + 6


def luminance(r: int, g: int, b: int) -> float:
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def process_image(src_path: Path, dst_path: Path, drive_color: str) -> None:
    """Le src_path, remove fundo, recolore pixels nao dourados para a cor pedida.

    drive_color in {"white", "black"}.
    Estrategia:
    - gold => mantem
    - lum < 12 => transparente (fundo)
    - 12 <= lum < 36 => target color com alpha gradual (AA suave nas bordas)
    - lum >= 36 => target color com alpha 255 (corpo solido das letras)
    """
    img = Image.open(src_path).convert("RGBA")
    px = img.load()
    w, h = img.size

    target = (255, 255, 255) if drive_color == "white" else (0, 0, 0)

    for y in range(h):
        for x in range(w):
            r, g, b, _ = px[x, y]

            if is_gold(r, g, b):
                px[x, y] = (r, g, b, 255)
                continue

            lum = luminance(r, g, b)

            if lum < 12:
                px[x, y] = (0, 0, 0, 0)
            elif lum < 36:
                alpha = int((lum - 12) / (36 - 12) * 255)
                px[x, y] = (target[0], target[1], target[2], max(0, min(255, alpha)))
            else:
                px[x, y] = (target[0], target[1], target[2], 255)

    img.save(dst_path, "PNG")
    print(f"  -> {dst_path.name}")


def process_mark(src_path: Path, dst_path: Path) -> None:
    """So o simbolo DT (dourado). Tudo o que nao for dourado vira transparente."""
    img = Image.open(src_path).convert("RGBA")
    px = img.load()
    w, h = img.size

    for y in range(h):
        for x in range(w):
            r, g, b, _ = px[x, y]
            if is_gold(r, g, b):
                px[x, y] = (r, g, b, 255)
            else:
                px[x, y] = (0, 0, 0, 0)

    img.save(dst_path, "PNG")
    print(f"  -> {dst_path.name}")


def make_preview(name: str, bg_rgba) -> None:
    """Compoe o PNG transparente sobre um fundo dark/light para conferencia."""
    fg = Image.open(OUT_DIR / name).convert("RGBA")
    bg = Image.new("RGBA", fg.size, bg_rgba)
    bg.alpha_composite(fg)
    # downscale para preview leve
    target_w = 512
    if bg.width > target_w:
        scale = target_w / bg.width
        bg = bg.resize((target_w, int(bg.height * scale)), Image.LANCZOS)
    suffix = "dark" if bg_rgba == DARK_BG else "light"
    out = PREVIEW_DIR / f"_logo_preview_{name.replace('.png', '')}_{suffix}.png"
    bg.convert("RGB").save(out, "PNG")
    print(f"  preview -> {out.name}")


# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------

print("[1/5] full logo, dark mode (DRIVE branco)")
process_image(FULL_LOGO, OUT_DIR / "drive_time_logo_dark.png", "white")

print("[2/5] full logo, light mode (DRIVE preto)")
process_image(FULL_LOGO, OUT_DIR / "drive_time_logo_light.png", "black")

print("[3/5] texto, dark mode (DRIVE branco)")
process_image(TEXT_WHITE, OUT_DIR / "drive_time_text_dark.png", "white")

print("[4/5] texto, light mode (DRIVE preto)")
process_image(TEXT_GREY, OUT_DIR / "drive_time_text_light.png", "black")

print("[5/5] simbolo DT (universal)")
process_mark(MARK_ONLY, OUT_DIR / "drive_time_mark.png")

print("\nA gerar previews compostos sobre fundo dark/light...")
for name in (
    "drive_time_logo_dark.png",
    "drive_time_logo_light.png",
    "drive_time_text_dark.png",
    "drive_time_text_light.png",
    "drive_time_mark.png",
):
    bg = DARK_BG if "dark" in name or "mark" in name else LIGHT_BG
    make_preview(name, bg)
    # tambem renderiza o mark sobre fundo light, ja que e universal
    if "mark" in name:
        make_preview(name, LIGHT_BG)

print("\nTerminado. Ficheiros em:", OUT_DIR)
