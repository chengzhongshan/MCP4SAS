"""Integrity and transcription checks for the author's current PoC documents."""
import hashlib
import json
from pathlib import Path
import re
import unittest
import xml.etree.ElementTree as ET
import zipfile

ROOT = Path(__file__).resolve().parents[1]
DOCS = ROOT / 'docs/poc'
NS = dict(w='http://schemas.openxmlformats.org/wordprocessingml/2006/main',
          a='http://schemas.openxmlformats.org/drawingml/2006/main',
          r='http://schemas.openxmlformats.org/officeDocument/2006/relationships')


def normalize(value):
    return ' '.join(value.split())


def paragraph_text(element):
    return ''.join(node.text or '' if node.tag.endswith('}t') else '\t'
                   if node.tag.endswith('}tab') else '\n'
                   for node in element.iter() if node.tag in
                   {'{'+NS['w']+'}t', '{'+NS['w']+'}tab', '{'+NS['w']+'}br'})


class AuthorDocumentTests(unittest.TestCase):
    def test_originals_source_metadata_and_reader_transcriptions(self):
        metadata = json.loads((DOCS / 'document-sources.json').read_text())
        manifest = json.loads((ROOT / 'examples/poc/manifest.json').read_text())
        records = {r['file']: r for r in manifest['source_documents']}
        self.assertEqual(metadata['author_revision_date'], '2026-11-20')
        self.assertEqual(len(metadata['documents']), 2)
        image_count = 0
        for record in metadata['documents']:
            with self.subTest(document=record['file']):
                published = DOCS / record['file']
                self.assertEqual(hashlib.sha256(published.read_bytes()).hexdigest(), record['sha256'])
                self.assertEqual(records[record['file']]['sha256'], record['sha256'])
                reader = (DOCS / record['reader']).read_bytes()
                self.assertEqual(hashlib.sha256(reader).hexdigest(), record['reader_sha256'])
                plain = re.sub(r'\[([^\]]+)\]\([^)]+\)', r'\1', reader.decode('utf8'))
                plain = normalize(plain.replace('<br>', ' ').replace('\\|', '|'))
                with zipfile.ZipFile(published) as archive:
                    document = ET.fromstring(archive.read('word/document.xml'))
                    paragraphs = document.findall('.//w:body//w:p', NS)
                    for paragraph in paragraphs:
                        content = normalize(paragraph_text(paragraph))
                        if content:
                            self.assertIn(content, plain)
                    for image in record['images']:
                        data = archive.read(image['zip_member'])
                        self.assertEqual(data, (DOCS / image['file']).read_bytes())
                        self.assertEqual(hashlib.sha256(data).hexdigest(), image['sha256'])
                        image_count += 1
        self.assertEqual(image_count, 6)

    def test_current_download_links_and_assembly_note(self):
        for page in (ROOT / 'README.md', DOCS / 'README.md'):
            content = page.read_text(encoding='utf8')
            self.assertIn('MCP4SAS_Proof_of_Concept_Nove_20_2026.docx?raw=1', content)
            self.assertIn('MCP4SAS_Use_Case_Appendix_Nov_20_2026.docx?raw=1', content)
            self.assertNotIn('_Scientifically_Edited.docx?raw=1', content)
        note = (DOCS / 'DOCUMENT_UPDATE_20261121.md').read_text(encoding='utf8')
        self.assertIn('GRCh38', note)
        self.assertIn('GRCh37', note)
        self.assertIn('assembly-provenance-discrepancy', (DOCS / 'use-case-appendix.md').read_text(encoding='utf8'))


if __name__ == '__main__':
    unittest.main()
