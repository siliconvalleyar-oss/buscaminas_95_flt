"""Generate iOS AppIcon PNGs from logo.png for Buscaminas 98."""
from PIL import Image
import os
import re

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LOGO_PATH = os.path.join(BASE_DIR, "assets", "logo.png")
ICONSET_DIR = os.path.join(
    BASE_DIR, "ios", "Runner", "Assets.xcassets", "AppIcon.appiconset"
)

if not os.path.exists(LOGO_PATH):
    print(f"✗ Logo not found: {LOGO_PATH}")
    exit(1)

logo = Image.open(LOGO_PATH).convert("RGBA")

# iOS icon sizes from Contents.json: (filename, base_size, scale)
# scale: 1x=1, 2x=2, 3x=3
icons = [
    ("Icon-App-20x20@1x.png", 20, 1),
    ("Icon-App-20x20@2x.png", 20, 2),
    ("Icon-App-20x20@3x.png", 20, 3),
    ("Icon-App-29x29@1x.png", 29, 1),
    ("Icon-App-29x29@2x.png", 29, 2),
    ("Icon-App-29x29@3x.png", 29, 3),
    ("Icon-App-40x40@1x.png", 40, 1),
    ("Icon-App-40x40@2x.png", 40, 2),
    ("Icon-App-40x40@3x.png", 40, 3),
    ("Icon-App-60x60@2x.png", 60, 2),
    ("Icon-App-60x60@3x.png", 60, 3),
    ("Icon-App-76x76@1x.png", 76, 1),
    ("Icon-App-76x76@2x.png", 76, 2),
    ("Icon-App-83.5x83.5@2x.png", 83.5, 2),
    ("Icon-App-1024x1024@1x.png", 1024, 1),
]

generated = 0
for filename, base_size, scale in icons:
    pixel_size = int(base_size * scale)
    out_path = os.path.join(ICONSET_DIR, filename)

    resized = logo.resize((pixel_size, pixel_size), Image.LANCZOS)

    # Create teal background square, paste logo on top
    bg = Image.new("RGBA", (pixel_size, pixel_size), (0, 128, 128, 255))
    bg.paste(resized, (0, 0), resized)

    # Save as RGB (iOS expects no alpha for icons)
    final = Image.new("RGB", (pixel_size, pixel_size), (0, 128, 128))
    final.paste(bg, (0, 0), bg)
    final.save(out_path, "PNG")
    print(f"  ✓ {filename} ({pixel_size}×{pixel_size})")
    generated += 1

print(f"\n✅ {generated} iOS icons generated in {ICONSET_DIR}")
