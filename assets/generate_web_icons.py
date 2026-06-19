"""Generate web favicon and PWA icons from logo.png for Buscaminas 98."""
from PIL import Image
import os

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LOGO_PATH = os.path.join(BASE_DIR, "assets", "logo.png")
WEB_DIR = os.path.join(BASE_DIR, "web")
ICONS_DIR = os.path.join(WEB_DIR, "icons")

if not os.path.exists(LOGO_PATH):
    print(f"✗ Logo not found: {LOGO_PATH}")
    exit(1)

logo = Image.open(LOGO_PATH).convert("RGBA")

def make_icon(pixel_size, filename):
    """Resize logo, paste on teal bg, save as RGB PNG."""
    out_path = os.path.join(ICONS_DIR, filename)
    resized = logo.resize((pixel_size, pixel_size), Image.LANCZOS)
    bg = Image.new("RGBA", (pixel_size, pixel_size), (0, 128, 128, 255))
    bg.paste(resized, (0, 0), resized)
    final = Image.new("RGB", (pixel_size, pixel_size), (0, 128, 128))
    final.paste(bg, (0, 0), bg)
    final.save(out_path, "PNG")
    print(f"  ✓ {filename} ({pixel_size}×{pixel_size})")

# Generate favicon (32x32 is standard)
favicon = logo.resize((32, 32), Image.LANCZOS)
favicon_bg = Image.new("RGBA", (32, 32), (0, 128, 128, 255))
favicon_bg.paste(favicon, (0, 0), favicon)
favicon_rgb = Image.new("RGB", (32, 32), (0, 128, 128))
favicon_rgb.paste(favicon_bg, (0, 0), favicon_bg)
favicon_rgb.save(os.path.join(WEB_DIR, "favicon.png"), "PNG")
print(f"  ✓ favicon.png (32×32)")

# Generate PWA icons
icons = [
    (192, "Icon-192.png"),
    (512, "Icon-512.png"),
    (192, "Icon-maskable-192.png"),
    (512, "Icon-maskable-512.png"),
]

for size, filename in icons:
    make_icon(size, filename)

print(f"\n✅ Web icons generated in {ICONS_DIR}")
