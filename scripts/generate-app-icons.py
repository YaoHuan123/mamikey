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
    img = Image.new("RGB", (size, size), BG)
    draw = ImageDraw.Draw(img)
    margin = size * 0.18
    # App Store icons must be fully opaque (no alpha channel)
    inner = (
        int(BG[0] * 0.85 + 255 * 0.15),
        int(BG[1] * 0.85 + 255 * 0.15),
        int(BG[2] * 0.85 + 255 * 0.15),
    )
    draw.rounded_rectangle(
        (margin, margin, size - margin, size - margin),
        radius=size * 0.14,
        fill=inner,
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


def save_icon(img: Image.Image, path: Path) -> None:
    # Force opaque RGB PNG (no alpha) — required for 1024 App Store icon
    rgb = img.convert("RGB")
    rgb.save(path, format="PNG")


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    for name, px in ICONS:
        save_icon(draw_icon(px), OUT / name)
        print(f"Wrote {name} ({px}x{px})")


if __name__ == "__main__":
    main()
