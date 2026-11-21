#!/usr/bin/env python3
"""Arrange the original PoC images at equal height, without cropping or stretching.

Developer-only dependency: Pillow. Run from any directory. The PNG is used on
GitHub because one responsive image scales every panel by the same factor.
The self-contained SVG remains available for manual layout editing.
"""
import base64
import hashlib
import io
import json
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
HEIGHT, GAP = 1000, 20
PANELS = (
    ("appendix-1.png", "GTEx expression clustergram"),
    ("appendix-3.png", "Synthetic mutation oncoprint"),
    ("appendix-5.png", "Three regional GWAS panels and gene annotations"),
)


def main():
    destination = ROOT / "previews"
    destination.mkdir(exist_ok=True)
    records, resized, x = [], [], 0
    for filename, title in PANELS:
        source = ROOT / "figures" / filename
        data = source.read_bytes()
        with Image.open(io.BytesIO(data)) as image:
            width = round(image.width * HEIGHT / image.height)
            records.append(dict(source="figures/" + filename, title=title,
                                sha256=hashlib.sha256(data).hexdigest(),
                                original_width=image.width, original_height=image.height,
                                x=x, y=0, width=width, height=HEIGHT))
            resized.append(image.convert("RGB").resize((width, HEIGHT), Image.Resampling.LANCZOS))
        x += width + GAP
    width = x - GAP
    canvas = Image.new("RGB", (width, HEIGHT), "white")
    elements = []
    for record, image in zip(records, resized):
        canvas.paste(image, (record["x"], 0))
        encoded = base64.b64encode((ROOT / record["source"]).read_bytes()).decode("ascii")
        elements.append(
            f'<image x="{record["x"]}" y="0" width="{record["width"]}" height="{HEIGHT}" '
            f'preserveAspectRatio="xMidYMid meet" href="data:image/png;base64,{encoded}">'
            f'<title>{record["title"]}</title></image>')
    canvas.save(destination / "homepage-figures.png", optimize=True)
    svg = (f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{HEIGHT}" '
           f'viewBox="0 0 {width} {HEIGHT}" role="img" aria-labelledby="title desc">\n'
           '<title id="title">Three SAS PoC figures at equal height</title>\n'
           '<desc id="desc">Expression clustergram; synthetic mutation oncoprint; '
           'three-panel regional GWAS. Original aspect ratios are preserved.</desc>\n'
           f'<rect width="{width}" height="{HEIGHT}" fill="white"/>\n' +
           "\n".join(elements) + "\n</svg>\n")
    (destination / "homepage-figures.svg").write_text(svg, encoding="utf8")
    (destination / "manifest.json").write_text(json.dumps(
        dict(width=width, height=HEIGHT, gap=GAP, panels=records), indent=2) + "\n", encoding="utf8")
    print(f"Created {width} x {HEIGHT} preview: all three panels have height {HEIGHT}.")


if __name__ == "__main__":
    main()
