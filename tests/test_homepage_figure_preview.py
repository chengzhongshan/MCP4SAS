"""Check the homepage layout without SAS, Pillow, or browser dependencies."""
import base64
import hashlib
import json
from pathlib import Path
import struct
import unittest
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
PREVIEWS = ROOT / "docs/poc/previews"


class HomepageFigurePreviewTests(unittest.TestCase):
    def test_equal_height_original_proportions_and_sources(self):
        manifest = json.loads((PREVIEWS / "manifest.json").read_text())
        images = ET.parse(PREVIEWS / "homepage-figures.svg").findall("{http://www.w3.org/2000/svg}image")
        self.assertEqual(len(images), 3)
        self.assertEqual(len(manifest["panels"]), 3)
        for panel, image in zip(manifest["panels"], images):
            with self.subTest(source=panel["source"]):
                original = (ROOT / "docs/poc" / panel["source"]).read_bytes()
                self.assertEqual(hashlib.sha256(original).hexdigest(), panel["sha256"])
                self.assertEqual(base64.b64decode(image.attrib["href"].split(",", 1)[1]), original)
                self.assertEqual(int(image.attrib["height"]), manifest["height"])
                self.assertEqual(int(image.attrib["y"]), 0)
                self.assertEqual(image.attrib["preserveAspectRatio"], "xMidYMid meet")
                self.assertLessEqual(abs(panel["width"] - panel["original_width"] *
                                         manifest["height"] / panel["original_height"]), 0.5)
        png = (PREVIEWS / "homepage-figures.png").read_bytes()
        self.assertEqual(png[:8], b"\x89PNG\r\n\x1a\n")
        self.assertEqual(struct.unpack(">II", png[16:24]), (manifest["width"], manifest["height"]))
        homepage = (ROOT / "README.md").read_text(encoding="utf8")
        self.assertIn('width="100%"', homepage)
        self.assertIn('src="docs/poc/previews/homepage-figures.png"', homepage)
        self.assertNotIn('width="31%"', homepage)


if __name__ == "__main__":
    unittest.main()
