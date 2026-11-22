#!/usr/bin/env python3
"""Publish unchanged author DOCX files and faithful Markdown reader copies.

Uses only the standard library. Does not regenerate SAS programs or inputs.
Run with --source-dir pointing to the author's MCP4SAS_POC_20261112 folder.
"""
import argparse
import hashlib
import json
from pathlib import Path
import posixpath
import re
import xml.etree.ElementTree as ET
import zipfile

ROOT = Path(__file__).resolve().parents[3]
DOCS = ROOT / 'docs/poc'
NS = dict(w='http://schemas.openxmlformats.org/wordprocessingml/2006/main',
          a='http://schemas.openxmlformats.org/drawingml/2006/main',
          r='http://schemas.openxmlformats.org/officeDocument/2006/relationships')
SPECS = (
    ('MCP4SAS_Proof_of_Concept_Nove_20_2026.docx', 'proof-of-concept.md', 'poc'),
    ('MCP4SAS_Use_Case_Appendix_Nov_20_2026.docx', 'use-case-appendix.md', 'appendix'),
)


def sha(data):
    return hashlib.sha256(data).hexdigest()


def text(element):
    return ''.join(n.text or '' if n.tag == '{'+NS['w']+'}t'
                   else '\t' if n.tag == '{'+NS['w']+'}tab' else '\n'
                   for n in element.iter() if n.tag in
                   {'{'+NS['w']+'}t', '{'+NS['w']+'}tab', '{'+NS['w']+'}br'})


def publish(source_dir):
    sources, provenance = [], []
    for filename, reader, prefix in SPECS:
        data = (source_dir / filename).read_bytes()
        with zipfile.ZipFile(source_dir / filename) as archive:
            body = ET.fromstring(archive.read('word/document.xml')).find('w:body', NS)
            relationships = {r.attrib['Id']: r.attrib for r in ET.fromstring(
                archive.read('word/_rels/document.xml.rels'))}
            lines = []
            if prefix == 'appendix':
                lines += ['# MCP4SAS scientific use case appendix', '']
            lines += [f'Reader transcription of the [author-supplied Word document]({filename}), updated 20 November 2026. Scientific wording, tables and embedded figures are retained. See the [showcase guide](README.md) for runnable examples and evidence scope.', '']
            if prefix == 'appendix':
                lines += ['**Assembly provenance note:** the author’s updated appendix says GRCh38, while the frozen example source/provenance records GRCh37. The supplied wording is preserved; see the [document update record](DOCUMENT_UPDATE_20261121.md#assembly-provenance-discrepancy) before reusing genomic coordinates.', '']
            images, code, paragraphs, tables = [], [], [], []
            for block in body:
                if block.tag == '{'+NS['w']+'}p':
                    for blip in block.findall('.//a:blip', NS):
                        rel = relationships[blip.attrib['{'+NS['r']+'}embed']]
                        if rel.get('TargetMode') == 'External':
                            raise ValueError('External image cannot be silently substituted')
                        entry = posixpath.normpath('word/'+rel['Target'].replace('\\', '/'))
                        if not entry.startswith('word/media/'):
                            raise ValueError('Unexpected image location: '+entry)
                        image_data = archive.read(entry)
                        path = f'figures/{prefix}-{len(images)+1}{Path(entry).suffix}'
                        (DOCS / path).write_bytes(image_data)
                        images.append(dict(file=path, sha256=sha(image_data), zip_member=entry))
                        lines += [f'![Figure {len(images)} from the updated author {prefix} document]({path})', '']
                    content = text(block)
                    if not content.strip():
                        continue
                    paragraphs.append(content)
                    if code or content.startswith('%SNP_Local_Manhattan_With_GTF('):
                        code.append(content)
                        if content.rstrip().endswith(');'):
                            lines += ['```sas', *code, '```', '']
                            code = []
                        continue
                    style = block.find('w:pPr/w:pStyle', NS)
                    style = style.attrib.get('{'+NS['w']+'}val', '') if style is not None else ''
                    heading = {'Title': '# ', 'Heading1': '## ',
                               'Heading2': '### ' if prefix == 'appendix' else '## '}.get(style, '')
                    content = re.sub(r'programs/(?:clustergram|gene_gtf|oncoprint|forest|multi_gwas_gtf)\.sas',
                                     lambda m: f'[{m[0]}](../../examples/poc/{m[0]})', content)
                    lines += [heading+content, '']
                elif block.tag == '{'+NS['w']+'}tbl':
                    rows = []
                    for row in block.findall('w:tr', NS):
                        cells = ['<br>'.join(text(p) for p in cell.findall('w:p', NS))
                                 for cell in row.findall('w:tc', NS)]
                        rows.append(cells)
                        lines.append('| '+' | '.join(c.replace('|', '\\|').replace('\n', '<br>') for c in cells)+' |')
                        if len(rows) == 1:
                            lines.append('| '+' | '.join('---' for _ in cells)+' |')
                    lines.append('')
                    tables.append(rows)
            if code:
                raise ValueError('Unterminated SAS excerpt')
            rendered = ('\n'.join(line.rstrip() for line in lines).rstrip()+'\n').encode('utf8')
            (DOCS / filename).write_bytes(data)
            (DOCS / reader).write_bytes(rendered)
            sources.append(dict(policy='Unmodified author-supplied document updated 20 November 2026',
                                sha256=sha(data), file=filename))
            provenance.append(dict(file=filename, sha256=sha(data), reader=reader,
                                   reader_sha256=sha(rendered), images=images,
                                   nonempty_body_paragraphs=len(paragraphs), tables=len(tables),
                                   source_text_sha256=sha(json.dumps(dict(paragraphs=paragraphs, tables=tables), ensure_ascii=False).encode('utf8'))))
    path = ROOT / 'examples/poc/manifest.json'
    existing = path.read_text(encoding='utf8')
    match = re.search(r'"source_documents"\s*:\s*', existing)
    _, end = json.JSONDecoder().raw_decode(existing[match.end():])
    replacement = json.dumps(sources, indent=4)
    path.write_text(existing[:match.end()]+replacement+existing[match.end()+end:], encoding='utf8')
    (DOCS / 'document-sources.json').write_text(json.dumps(dict(
        update_date='2026-11-21', author_revision_date='2026-11-20',
        policy='Byte-identical Word originals; reader transcription only. Frozen SAS programs, inputs and execution reports are unchanged.',
        documents=provenance), indent=2)+'\n', encoding='utf8')
    print('Published two unchanged Word documents, two reader copies and six embedded images.')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source-dir', required=True, type=Path)
    publish(parser.parse_args().source_dir.resolve(strict=True))
