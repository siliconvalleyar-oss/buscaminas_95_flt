"""Generate Android mipmap icons from logo.png for Buscaminas 98."""
from PIL import Image
import os

# Android mipmap densities and their sizes
# mdpi = 48x48, hdpi = 72x72, xhdpi = 96x96, xxhdpi = 144x144, xxxhdpi = 192x192
ANDROID_SIZES = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LOGO_PATH = os.path.join(BASE_DIR, "assets", "logo.png")
RES_DIR = os.path.join(BASE_DIR, "android", "app", "src", "main", "res")

if not os.path.exists(LOGO_PATH):
    print(f"✗ Logo not found: {LOGO_PATH}")
    exit(1)

logo = Image.open(LOGO_PATH).convert("RGBA")

for folder, size in ANDROID_SIZES.items():
    folder_path = os.path.join(RES_DIR, folder)
    out_path = os.path.join(folder_path, "ic_launcher.png")

    if not os.path.exists(folder_path):
        print(f"⚠  Folder not found: {folder_path}, skipping")
        continue

    resized = logo.resize((size, size), Image.LANCZOS)

    # Create a square background with the teal color
    bg = Image.new("RGBA", (size, size), (0, 128, 128, 255))
    # Composite the resized logo onto the background
    bg.paste(resized, (0, 0), resized)

    # Convert to RGB for PNG save (no alpha for Android icon)
    final = Image.new("RGB", (size, size), (0, 128, 128))
    final.paste(bg, (0, 0), bg)

    final.save(out_path, "PNG")
    print(f"✓ {folder}/ic_launcher.png ({size}x{size})")

print("\nAll Android icons generated!")
