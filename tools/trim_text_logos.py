"""Trim transparent / near-transparent padding around the DRIVE TIME text logos.

The text variants currently come as 1536x1024 PNGs with significant transparent
margins around the actual text. When we size the Image widget by height the
text ends up looking tiny because most of the rendered box is empty.

We crop the bounding box of pixels whose alpha is above a threshold so that
the image becomes (almost) only the text itself.
"""
from pathlib import Path

from PIL import Image

ASSETS = Path(__file__).resolve().parent.parent / "assets" / "images"

SOURCES = [
    ASSETS / "drive_time_text_light.png",
    ASSETS / "drive_time_text_dark.png",
]

# We also trim the full logos (the ones that include the tagline) so they
# render larger in the same vertical space on Login / Register.
SOURCES += [
    ASSETS / "drive_time_logo_light.png",
    ASSETS / "drive_time_logo_dark.png",
]

ALPHA_THRESHOLD = 60  # ignore pixels fainter than this


def trim(path: Path) -> None:
    """Crop transparent margins, ignoring isolated noise pixels.

    We dilate-then-erode the alpha mask with a 3x3 minimum filter so single
    stray pixels (artefacts from earlier image-processing passes) don't expand
    the bounding box. We then crop the ORIGINAL image to that cleaned bbox.
    """
    if not path.exists():
        print(f"skip (missing): {path}")
        return
    from PIL import ImageFilter

    img = Image.open(path).convert("RGBA")
    alpha = img.getchannel("A")
    mask = alpha.point(lambda v: 255 if v >= ALPHA_THRESHOLD else 0)
    # remove specks: pixels without neighbours die out
    cleaned = mask.filter(ImageFilter.MinFilter(3))
    bbox = cleaned.getbbox()
    if not bbox:
        # fall back to the raw bbox if cleaning removed everything (very tiny logos)
        bbox = mask.getbbox()
    if not bbox:
        print(f"empty alpha, skip: {path}")
        return
    cropped = img.crop(bbox)
    print(f"{path.name}: {img.size} -> {cropped.size} (bbox {bbox})")
    cropped.save(path)


if __name__ == "__main__":
    for src in SOURCES:
        trim(src)
