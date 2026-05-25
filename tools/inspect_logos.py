"""Inspecciona os PNGs enviados e gera um relatorio para cada um:
- dimensoes
- tem canal alpha? (transparente vs solido)
- % de pixels totalmente transparentes
- amostra de cores principais (dourado, branco, cinzento, preto)
- previews 1:1 e composto sobre branco/preto para confirmacao
"""

from pathlib import Path
from collections import Counter

from PIL import Image

SRC_DIR = Path(r"C:\Users\Diogo Terrivel\.cursor\projects\c-Users-Diogo-Terrivel-Desktop-drive-time-duplicated\assets")

# Os 7 ficheiros mais recentes que o utilizador acabou de enviar.
NEW = {
    "img1_text_dark_grey":  "c__Users_Diogo_Terrivel_AppData_Roaming_Cursor_User_workspaceStorage_empty-window_images_ChatGPT_Image_25_05_2026__23_18_32-0224a016-f225-41e6-842c-db8ed635c108.png",
    "img2_text_white":      "c__Users_Diogo_Terrivel_AppData_Roaming_Cursor_User_workspaceStorage_empty-window_images_ChatGPT_Image_25_05_2026__23_25_16-bdc8f802-dbf9-481e-97a1-cbff4f1f0916.png",
    "img3_text_grey":       "c__Users_Diogo_Terrivel_AppData_Roaming_Cursor_User_workspaceStorage_empty-window_images_ChatGPT_Image_25_05_2026__23_06_29-a5333cc3-7f17-4618-9f53-8fe1b112b63f.png",
    "img4_full_grey":       "c__Users_Diogo_Terrivel_AppData_Roaming_Cursor_User_workspaceStorage_empty-window_images_ChatGPT_Image_25_05_2026__23_06_47-c1fa3d69-2895-4eab-8ebe-28d64d3f1b25.png",
    "img5_mark":            "c__Users_Diogo_Terrivel_AppData_Roaming_Cursor_User_workspaceStorage_empty-window_images_ChatGPT_Image_25_05_2026__23_17_59-da451c95-f390-4cba-a07c-8f3f30e77194.png",
    "img6_full_white":      "c__Users_Diogo_Terrivel_AppData_Roaming_Cursor_User_workspaceStorage_empty-window_images_ChatGPT_Image_25_05_2026__23_18_08-2eaf9329-a198-4cf6-bd3c-ca25623496b8.png",
    "img7_full_grey_v2":    "c__Users_Diogo_Terrivel_AppData_Roaming_Cursor_User_workspaceStorage_empty-window_images_ChatGPT_Image_25_05_2026__23_18_15-b983bfea-cef1-4766-9ff1-bbee78b13502.png",
}

PREV_DIR = Path(r"C:\Users\Diogo Terrivel\Desktop\drive-time-duplicated\tools")
PREV_DIR.mkdir(parents=True, exist_ok=True)


def summarise(label: str, path: Path) -> None:
    img = Image.open(path)
    print(f"\n--- {label} ---")
    print(f"   file:        {path.name[:80]}...")
    print(f"   mode:        {img.mode}")
    print(f"   size:        {img.size[0]} x {img.size[1]}")

    rgba = img.convert("RGBA")
    px = list(rgba.getdata())
    total = len(px)

    fully_transparent = sum(1 for p in px if p[3] == 0)
    fully_opaque = sum(1 for p in px if p[3] == 255)
    semi = total - fully_transparent - fully_opaque

    print(f"   transparente: {fully_transparent / total * 100:5.1f}%  "
          f"opaco: {fully_opaque / total * 100:5.1f}%  "
          f"semi: {semi / total * 100:5.1f}%")

    # cores dominantes entre pixels opacos
    bucket = Counter()
    for r, g, b, a in px:
        if a < 128:
            continue
        # arredonda para reduzir variedade
        bucket[(r // 32 * 32, g // 32 * 32, b // 32 * 32)] += 1
    top = bucket.most_common(5)
    print("   top cores opacas (R,G,B -> contagem):")
    for c, n in top:
        kind = describe(*c)
        print(f"      {c}   {n:>8}   {kind}")

    # preview composto sobre branco e preto, para ver se tem realmente transparencia
    for bg, tag in (((0, 0, 0, 255), "black"), ((255, 255, 255, 255), "white")):
        base = Image.new("RGBA", rgba.size, bg)
        base.alpha_composite(rgba)
        target = base.convert("RGB")
        # downscale
        target.thumbnail((420, 420), Image.LANCZOS)
        out = PREV_DIR / f"_inspect_{label}_on_{tag}.png"
        target.save(out, "PNG")
    print(f"   previews:    _inspect_{label}_on_black.png / _on_white.png")


def describe(r: int, g: int, b: int) -> str:
    if r < 32 and g < 32 and b < 32:
        return "preto/fundo"
    if r > 200 and g > 200 and b > 200:
        return "branco"
    if r > b + 40 and g > b + 20 and r > 100:
        return "dourado"
    if abs(r - g) < 32 and abs(g - b) < 32 and abs(r - b) < 32:
        return "cinzento"
    return "outra"


for label, fname in NEW.items():
    summarise(label, SRC_DIR / fname)
