"""Limpa artefactos (riscas verticais / ruido) das imagens DARK que o ChatGPT
deixou no fundo, e forca o DRIVE a branco puro opaco. Preserva o dourado.

Estrategia:
- alpha < ALPHA_FLOOR (~60) => fundo (transparente)
- pixel dourado => mantem tonalidade e forca alpha 255 se ja era razoavel,
  caso contrario zera (e ruido fino)
- pixel nao dourado, alpha alto => DRIVE => (255,255,255,255)

So altera os ficheiros DARK (logo_dark, text_dark). Light e mark sao
re-copiados das fontes originais antes para nao ficarem afetados por
execucoes anteriores deste script.
"""

import shutil
from pathlib import Path

from PIL import Image

ASSETS = Path(r"C:\Users\Diogo Terrivel\Desktop\drive-time-duplicated\assets\images")
SRC = ASSETS / "source"

# Re-copia originais para garantir estado limpo antes do boost
COPY = {
    "drive_time_logo_dark.png":  "logo_completo_dark.png.png",
    "drive_time_logo_light.png": "logo_completo_light.png.png",
    "drive_time_text_dark.png":  "texto_dark.png.png",
    "drive_time_text_light.png": "texto_light.png.png",
    "drive_time_mark.png":       "simbolo_dt.png.png",
}
for dst, src in COPY.items():
    shutil.copyfile(SRC / src, ASSETS / dst)
    print(f"copiado {src} -> {dst}")

TARGETS = ["drive_time_logo_dark.png", "drive_time_text_dark.png"]

# Qualquer pixel com alpha abaixo deste valor e considerado ruido / fundo
ALPHA_FLOOR = 80


def is_gold(r: int, g: int, b: int) -> bool:
    if r + g + b < 60:
        return False
    if max(r, g, b) - min(r, g, b) < 25:
        return False
    return r >= b + 25 and g >= b + 8


for name in TARGETS:
    path = ASSETS / name
    img = Image.open(path).convert("RGBA")
    px = img.load()
    w, h = img.size
    cleaned = 0
    boosted_text = 0
    kept_gold = 0
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a == 0:
                continue
            if a < ALPHA_FLOOR:
                # ruido / artefacto => limpa
                px[x, y] = (0, 0, 0, 0)
                cleaned += 1
                continue
            if is_gold(r, g, b):
                px[x, y] = (r, g, b, 255)
                kept_gold += 1
            else:
                px[x, y] = (255, 255, 255, 255)
                boosted_text += 1
    img.save(path, "PNG", optimize=True)
    print(
        f"{name}: limpou={cleaned}  DRIVE-branco={boosted_text}  dourado-mantido={kept_gold}"
    )
