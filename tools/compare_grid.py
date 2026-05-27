"""Gera uma grelha de comparacao das 7 novas variantes:
- 7 linhas (uma por imagem)
- 2 colunas: composta sobre fundo dark #050505 e fundo light #F8FAFC
- com etiquetas para identificar cada uma
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

SRC_DIR = Path(r"C:\Users\Diogo Terrivel\.cursor\projects\c-Users-Diogo-Terrivel-Desktop-drive-time-duplicated\assets")
OUT = Path(r"C:\Users\Diogo Terrivel\Desktop\drive-time-duplicated\tools\_compare_grid.png")

ITEMS = [
    ("1. text DRIVE cinzento",  "c__Users_Diogo_Terrivel_AppData_Roaming_Cursor_User_workspaceStorage_empty-window_images_ChatGPT_Image_25_05_2026__23_18_32-0224a016-f225-41e6-842c-db8ed635c108.png"),
    ("2. text DRIVE branco",    "c__Users_Diogo_Terrivel_AppData_Roaming_Cursor_User_workspaceStorage_empty-window_images_ChatGPT_Image_25_05_2026__23_25_16-bdc8f802-dbf9-481e-97a1-cbff4f1f0916.png"),
    ("3. text DRIVE cinzento (=1)", "c__Users_Diogo_Terrivel_AppData_Roaming_Cursor_User_workspaceStorage_empty-window_images_ChatGPT_Image_25_05_2026__23_06_29-a5333cc3-7f17-4618-9f53-8fe1b112b63f.png"),
    ("4. full+tagline 'TENPO.' typo", "c__Users_Diogo_Terrivel_AppData_Roaming_Cursor_User_workspaceStorage_empty-window_images_ChatGPT_Image_25_05_2026__23_06_47-c1fa3d69-2895-4eab-8ebe-28d64d3f1b25.png"),
    ("5. simbolo DT",           "c__Users_Diogo_Terrivel_AppData_Roaming_Cursor_User_workspaceStorage_empty-window_images_ChatGPT_Image_25_05_2026__23_17_59-da451c95-f390-4cba-a07c-8f3f30e77194.png"),
    ("6. full+tagline 'TEMPO,' DRIVE branco", "c__Users_Diogo_Terrivel_AppData_Roaming_Cursor_User_workspaceStorage_empty-window_images_ChatGPT_Image_25_05_2026__23_18_08-2eaf9329-a198-4cf6-bd3c-ca25623496b8.png"),
    ("7. full+tagline 'TEMPO,' DRIVE cinzento", "c__Users_Diogo_Terrivel_AppData_Roaming_Cursor_User_workspaceStorage_empty-window_images_ChatGPT_Image_25_05_2026__23_18_15-b983bfea-cef1-4766-9ff1-bbee78b13502.png"),
]

DARK = (5, 5, 5)
LIGHT = (248, 250, 252)

CELL_W = 360
CELL_H = 240
LABEL_W = 260
PAD = 8

font = ImageFont.load_default()

rows = len(ITEMS)
grid_w = LABEL_W + 2 * CELL_W + 3 * PAD
grid_h = rows * CELL_H + (rows + 1) * PAD + 40

canvas = Image.new("RGB", (grid_w, grid_h), (24, 24, 28))
draw = ImageDraw.Draw(canvas)
draw.text((PAD, 6), "DARK MODE (#050505)", fill=(220, 220, 220), font=font)
draw.text((LABEL_W + 2 * PAD + CELL_W, 6), "LIGHT MODE (#F8FAFC)", fill=(220, 220, 220), font=font)

for i, (label, fname) in enumerate(ITEMS):
    img = Image.open(SRC_DIR / fname).convert("RGB")
    img.thumbnail((CELL_W, CELL_H), Image.LANCZOS)
    # dark cell: replace black with dark bg (background already is black)
    # light cell: need to invert background -> paste image on light, then make sure original black bg shows
    dark_cell = Image.new("RGB", (CELL_W, CELL_H), DARK)
    light_cell = Image.new("RGB", (CELL_W, CELL_H), LIGHT)
    # offset to center the thumbnail
    offset = ((CELL_W - img.width) // 2, (CELL_H - img.height) // 2)
    dark_cell.paste(img, offset)
    # For the light cell, simulate "what if we removed the black bg":
    # convert to RGBA, set black pixels to alpha 0, then composite on light bg
    rgba = img.convert("RGBA")
    data = rgba.load()
    for y in range(img.height):
        for x in range(img.width):
            r, g, b, _ = data[x, y]
            if r < 18 and g < 18 and b < 18:
                data[x, y] = (0, 0, 0, 0)
    light_cell_base = Image.new("RGBA", (CELL_W, CELL_H), LIGHT + (255,))
    light_cell_base.alpha_composite(rgba, offset)
    light_cell = light_cell_base.convert("RGB")

    y = 40 + i * (CELL_H + PAD)
    # label
    draw.rectangle([0, y, LABEL_W, y + CELL_H], fill=(40, 40, 46))
    draw.multiline_text((PAD, y + 12), label, fill=(255, 215, 0), font=font, spacing=4)
    # cells
    canvas.paste(dark_cell, (LABEL_W + PAD, y))
    canvas.paste(light_cell, (LABEL_W + 2 * PAD + CELL_W, y))

OUT.parent.mkdir(parents=True, exist_ok=True)
canvas.save(OUT, "PNG")
print("OK ->", OUT)
