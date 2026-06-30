"""Normalize Play Store screenshots to recommended dimensions."""
from __future__ import annotations

import os
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
PHONE_TARGET = (1080, 1920)
TABLET_LANDSCAPE_TARGET = (2560, 1600)


def fit_and_crop(img: Image.Image, target_w: int, target_h: int) -> Image.Image:
    target_ratio = target_w / target_h
    src_w, src_h = img.size
    src_ratio = src_w / src_h

    if src_ratio > target_ratio:
        new_h = target_h
        new_w = int(src_w * (target_h / src_h))
    else:
        new_w = target_w
        new_h = int(src_h * (target_w / src_w))

    resized = img.resize((new_w, new_h), Image.LANCZOS)
    left = max(0, (new_w - target_w) // 2)
    top = max(0, (new_h - target_h) // 2)
    return resized.crop((left, top, left + target_w, top + target_h))


def process_folder(folder: Path, target: tuple[int, int]) -> None:
    for path in sorted(folder.glob("[0-9][0-9]-*.png")):
        with Image.open(path) as img:
            rgb = img.convert("RGB")
            out = fit_and_crop(rgb, *target)
            out.save(path, format="PNG", optimize=True)
            print(f"{path.name}: {out.size[0]}x{out.size[1]}")


def main() -> None:
    phone_dir = ROOT / "play-store" / "screenshots" / "phone"
    tablet_dir = ROOT / "play-store" / "screenshots" / "tablet"

    if phone_dir.exists() and any(phone_dir.glob("*.png")):
        print("Phone screenshots:")
        process_folder(phone_dir, PHONE_TARGET)

    if tablet_dir.exists() and any(tablet_dir.glob("*.png")):
        print("Tablet screenshots:")
        process_folder(tablet_dir, TABLET_LANDSCAPE_TARGET)


if __name__ == "__main__":
    main()
