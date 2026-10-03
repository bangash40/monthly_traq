"""Renders the app icon — the "month donut": a calendar page with a spending
donut on it — to the PNGs the launcher-icon and splash generators read.

    python tool/render_icon.py
    dart run flutter_launcher_icons
    dart run flutter_native_splash:create

Writes assets/icon/icon.png (the full square icon) and
assets/icon/icon_foreground.png (the adaptive-icon foreground, also used on
the splash screen). Needs Pillow (`pip install pillow`).

The colors follow the default theme (Sage). If you change TILE here, change
`adaptive_icon_background` and the splash `icon_background_color` values in
pubspec.yaml to match. The in-app logo (AppLogoTile in lib/widgets/ui.dart)
draws the same shapes on the same 100-unit grid.
"""
import sys
from pathlib import Path

from PIL import Image, ImageDraw


def hex_rgba(value):
    value = value.lstrip('#')
    return tuple(int(value[i:i + 2], 16) for i in (0, 2, 4)) + (255,)


TILE = hex_rgba('#E3EFE8')    # icon background: a soft sage
BRAND = hex_rgba('#2F6B55')   # Sage primary: header, rings, first segment
BORDER = hex_rgba('#C5D6CF')  # BRAND at 28% over white: the page's edge
MINT = hex_rgba('#5FC49E')    # second donut segment
AMBER = hex_rgba('#F59E0B')   # third donut segment
WHITE = (255, 255, 255, 255)
CLEAR = (0, 0, 0, 0)

SUPERSAMPLE = 4  # draw 4x larger, then shrink, for smooth edges


def draw_icon(d, s, ox, oy):
    """Draws the icon on a 100-unit grid: s = pixels per unit, (ox, oy) =
    where grid point (0, 0) lands."""

    def p(x, y):
        return (ox + x * s, oy + y * s)

    def rounded(x, y, w, h, r, fill):
        d.rounded_rectangle([p(x, y), p(x + w, y + h)], radius=r * s, fill=fill)

    # Calendar page with a thin tinted edge.
    rounded(24.25, 28.25, 51.5, 48.5, 10.75, BORDER)
    rounded(25.75, 29.75, 48.5, 45.5, 9.25, WHITE)
    # Header band (rounded top, square bottom) and the two binding rings.
    rounded(25.75, 29.75, 48.5, 12.25, 9.25, BRAND)
    d.rectangle([p(25.75, 36), p(74.25, 42)], fill=BRAND)
    rounded(35, 23, 5, 11, 2.5, BRAND)
    rounded(60, 23, 5, 11, 2.5, BRAND)

    # Spending donut: radius 10.5, ring 6.5 wide, clockwise from 12 o'clock
    # (Pillow measures angles clockwise from 3 o'clock).
    cx, cy, outer, width = 50, 59, 10.5 + 3.25, 6.5
    box = [p(cx - outer, cy - outer), p(cx + outer, cy + outer)]
    for start, sweep, color in [(-90, 169.2, BRAND), (92.84, 95.5, MINT),
                                (201.98, 54.6, AMBER)]:
        d.arc(box, start=start, end=start + sweep, fill=color,
              width=round(width * s))


def render(size, background, grid_units, offset_units):
    """A size x size image showing grid_units of the 100-unit grid, the
    grid's origin offset_units in from the top left."""
    big = size * SUPERSAMPLE
    image = Image.new('RGBA', (big, big), background)
    scale = big / grid_units
    draw_icon(ImageDraw.Draw(image), scale, offset_units * scale,
              offset_units * scale)
    return image.resize((size, size), Image.LANCZOS)


def main():
    out = Path(sys.argv[1] if len(sys.argv) > 1 else 'assets/icon')
    out.mkdir(parents=True, exist_ok=True)

    # Full icon: the artwork (which spans 25-75 of the grid) scaled up 1.2x.
    full = 100 / 1.2
    render(1024, TILE, full, (full - 100) / 2).save(out / 'icon.png')

    # Adaptive foreground, a 108dp layer: scaled so the artwork's farthest
    # point (the page's rounded corner, 32.7 units from the centre) sits on
    # Android's 33dp safe-zone circle — as large as it can be without any
    # launcher's mask clipping it.
    dp_per_unit = 33 / 32.7
    layer = 108 / dp_per_unit
    render(1024, CLEAR, layer, (layer - 100) / 2).save(
        out / 'icon_foreground.png')

    print(f'Wrote {out / "icon.png"} and {out / "icon_foreground.png"}')


if __name__ == '__main__':
    main()
