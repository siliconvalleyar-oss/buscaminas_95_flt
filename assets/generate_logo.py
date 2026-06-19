"""Generate logo.png for Buscaminas 98 app icon."""
from PIL import Image, ImageDraw

SIZE = 1024

img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)

# Background: Win98 teal
margin = 20
draw.rounded_rectangle(
    [margin, margin, SIZE - margin, SIZE - margin],
    radius=120,
    fill=(0, 128, 128, 255),
)

# Mine circle
cx, cy = SIZE // 2, SIZE // 2 - 30
mine_r = SIZE // 6

# Mine body
draw.ellipse(
    [cx - mine_r, cy - mine_r, cx + mine_r, cy + mine_r],
    fill=(30, 30, 30, 255),
)
# Highlight
hl_r = mine_r // 3
draw.ellipse(
    [cx - mine_r * 0.3, cy - mine_r * 0.3, cx, cy],
    fill=(180, 180, 180, 180),
)

# Spikes
spike_len = int(mine_r * 1.6)
import math
for angle_deg in [45, 135, 225, 315]:
    rad = math.radians(angle_deg)
    sx = cx + math.cos(rad) * mine_r * 0.6
    sy = cy + math.sin(rad) * mine_r * 0.6
    ex = cx + math.cos(rad) * spike_len
    ey = cy + math.sin(rad) * spike_len
    draw.line([sx, sy, ex, ey], fill=(30, 30, 30, 255), width=max(6, SIZE // 80))

# Flag
flag_x = cx + mine_r + 50
flag_y = cy - mine_r - 60
pole_top = flag_y - 40
pole_bottom = flag_y + mine_r * 1.2

# Pole
draw.line(
    [flag_x, pole_top, flag_x, pole_bottom],
    fill=(139, 90, 43, 255),
    width=max(8, SIZE // 80),
)
# Flag triangle
draw.polygon(
    [
        (flag_x, pole_top),
        (flag_x + mine_r * 1.5, pole_top + 70),
        (flag_x, pole_top + 140),
    ],
    fill=(220, 30, 30, 255),
)
# Flag highlight
draw.polygon(
    [
        (flag_x + 5, pole_top + 5),
        (flag_x + mine_r, pole_top + 70),
        (flag_x + 5, pole_top + 135),
    ],
    fill=(255, 80, 80, 180),
)

# Text
try:
    font_size = SIZE // 8
    try:
        from PIL import ImageFont
        font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", font_size)
    except (IOError, OSError):
        font = ImageFont.load_default()
    text = "98"
    bbox = draw.textbbox((0, 0), text, font=font)
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]
    tx = (SIZE - tw) // 2
    ty = cy + mine_r + 60
    # text shadow
    draw.text((tx + 3, ty + 3), text, fill=(0, 0, 0, 120), font=font)
    draw.text((tx, ty), text, fill=(255, 255, 255, 230), font=font)
except Exception:
    pass

img.save("logo.png", "PNG")
print("logo.png generated successfully!")
