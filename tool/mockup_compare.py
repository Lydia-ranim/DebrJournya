#!/usr/bin/env python3
"""Compare a screen's golden renders with its design mockups.

Usage (from the repo root):
  python3 -I tool/mockup_compare.py bands  <png>            # content bands of one image
  python3 -I tool/mockup_compare.py compare <mockup> <golden> [out.png]
  python3 -I tool/mockup_compare.py screen <id> <golden_prefix> [out_dir]
      e.g. screen "A3" test/goldens/screens/a3_language  →  compares
      <prefix>_fr_light.png with Docs/design/light/A3 · *.png and
      <prefix>_fr_dark.png with Docs/design/dark/A3 · * · sombre.png

"bands" are horizontal runs of rows that differ from the background, with
their x-extent: a quick way to read positions (in @2x px) off a mockup.
"compare" prints the bands of both images side by side (Δy, Δx per band) and
writes an image: mockup | render | difference heat-map.
Requires Pillow. Mockups and goldens are both 780 px wide (@2x of 390 pt).
"""
import glob
import os
import sys

from PIL import Image, ImageChops, ImageOps

TOL = 18  # per-channel distance from the background that counts as content


def load(path):
    return Image.open(path).convert("RGB")


def background(im):
    return im.getpixel((2, im.height // 2))


def bands(im, min_gap=4):
    bg = background(im)
    w, h = im.size
    px = im.load()
    rows = []
    for y in range(h):
        xs = [x for x in range(0, w, 2)
              if max(abs(a - b) for a, b in zip(px[x, y], bg)) > TOL]
        rows.append((min(xs), max(xs)) if xs else None)
    out, start, gap = [], None, 0
    for y, r in enumerate(rows + [None] * (min_gap + 1)):
        if r is not None:
            if start is None:
                start = y
            gap = 0
        elif start is not None:
            gap += 1
            if gap > min_gap:
                end = y - gap
                xs = [rows[i] for i in range(start, end + 1) if rows[i]]
                out.append((start, end, min(a for a, _ in xs), max(b for _, b in xs)))
                start, gap = None, 0
    return out


def fmt(b):
    return f"y {b[0]:4d}–{b[1]:4d} (h {b[1]-b[0]+1:3d})  x {b[2]:3d}–{b[3]:3d}"


def compare(mock_path, gold_path, out=None):
    m, g = load(mock_path), load(gold_path)
    bm, bg = bands(m), bands(g)
    print(f"{'mockup':42s} | {'render':42s} | Δtop Δbottom Δx0 Δx1")
    for i in range(max(len(bm), len(bg))):
        a = bm[i] if i < len(bm) else None
        b = bg[i] if i < len(bg) else None
        d = ""
        if a and b:
            d = f"{b[0]-a[0]:+4d} {b[1]-a[1]:+4d} {b[2]-a[2]:+4d} {b[3]-a[3]:+4d}"
        print(f"{fmt(a) if a else '-':42s} | {fmt(b) if b else '-':42s} | {d}")
    if out:
        h = max(m.height, g.height)
        g2 = g if g.size == m.size else g.resize(m.size)
        diff = ImageOps.autocontrast(ImageChops.difference(m, g2).convert("L"))
        diff = ImageOps.colorize(diff, "black", "#ff2d6f")
        sheet = Image.new("RGB", (m.width * 3 + 40, h), (255, 0, 128))
        for i, im in enumerate((m, g, diff)):
            sheet.paste(im, (i * (m.width + 20), 0))
        sheet.save(out)
        print(f"→ {out}")


def screen(sid, prefix, out_dir="."):
    for theme, folder, suffix in (("light", "light", ""), ("dark", "dark", " · sombre")):
        mocks = sorted(glob.glob(f"Docs/design/{folder}/{sid} · *{suffix}.png"))
        if theme == "light":
            mocks = [p for p in mocks if "sombre" not in p]
        gold = f"{prefix}_fr_{theme}.png"
        if not mocks or not os.path.exists(gold):
            print(f"[{theme}] missing mockup or golden ({mocks}, {gold})")
            continue
        print(f"\n[{theme}] {mocks[0]}  vs  {gold}")
        compare(mocks[0], gold, os.path.join(out_dir, f"{os.path.basename(prefix)}_{theme}_cmp.png"))


if __name__ == "__main__":
    cmd, *args = sys.argv[1:] or ["help"]
    if cmd == "bands":
        for b in bands(load(args[0])):
            print(fmt(b))
    elif cmd == "compare":
        compare(*args)
    elif cmd == "screen":
        screen(*args)
    else:
        print(__doc__)
