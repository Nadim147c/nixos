import os
import string

import fontforge

font = fontforge.font()
font.fontname = "PixelartIcons"
font.fullname = "PixelartIcons"
font.familyname = "PixelartIcons"
font.ascent = 800
font.descent = 200

# Create dummy empty glyphs for all basic ASCII characters
# required by FontForge to form valid GSUB ligature lookup tables
for char in string.ascii_lowercase + string.digits + "-_":
    if ord(char) not in font:
        g = font.createChar(ord(char), char)
        g.width = 0

font.addLookup("liga_lookup", "gsub_ligature", (), (("liga", (("latn", ("dflt")),)),))
font.addLookupSubtable("liga_lookup", "liga_subtable")

svg_dir = "./svg"
unicode_start = 0xE000

svg_files = sorted([f for f in os.listdir(svg_dir) if f.endswith(".svg")])

for i, filename in enumerate(svg_files):
    name = os.path.splitext(filename)[0]
    uni = unicode_start + i

    glyph = font.createChar(uni, name)
    glyph.importOutlines(os.path.join(svg_dir, filename))
    glyph.addPosSub("liga_subtable", tuple(name))

font.generate("pixelarticons.ttf")
font.generate("pixelarticons.woff2")
