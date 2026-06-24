#!/usr/bin/env python3
"""Generate Mami Key iOS AppIcon PNGs."""
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "ios" / "MamiKey" / "Assets.xcassets" / "AppIcon.appiconset"

# (filename, pixel size)
ICONS = [
    ("Icon-20@2x.png", 40),
    ("Icon-20@3x.png", 60),
    ("Icon-29@2x.png", 58),
    ("Icon-29@3x.png", 87),
    ("Icon-40@2x.png", 80),
    ("Icon-40@3x.png", 120),
    ("Icon-60@2x.png", 120),
    ("Icon-60@3x.png", 180),
    ("Icon-1024.png", 1024),
]

BG = (255, 107, 74)  # warm coral
FG = (255, 255, 255)


def draw_icon(size: int) -> Image.Image:
    img = Image.new("RGBA", (size, size), BG)
    draw = ImageDraw.Draw(img)
    margin = size * 0.18
    draw.rounded_rectangle(
        (margin, margin, size - margin, size - margin),
        radius=size * 0.14,
        fill=(255, 255, 255, 40),
    )
    font_size = int(size * 0.42)
    try:
        font = ImageFont.truetype("arial.ttf", font_size)
    except OSError:
        font = ImageFont.load_default()
    text = "妈"
    bbox = draw.textbbox((0, 0), text, font=font)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    draw.text(((size - tw) / 2, (size - th) / 2 - size * 0.04), text, fill=FG, font=font)
    return img


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    for name, px in ICONS:
        draw_icon(px).save(OUT / name, format="PNG")
        print(f"Wrote {name} ({px}x{px})")


if __name__ == "__main__":
    main()
