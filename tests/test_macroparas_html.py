"""Offline checks and validation of actual SAS macro-source HTML.

python tests/test_macroparas_html.py --html SAVED_HTML --write-copied copied.sas
extracts the two fixture macros exactly as browser text cells expose them.
No line-number stripping or nonbreaking-space repair is performed.
"""
import argparse
from html import escape
from html.parser import HTMLParser
from pathlib import Path
import sys
import unittest
from unittest.mock import patch

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT))
from MCP4SAS_Use_Python.dependencies import Plan
from tools.sync_macroparas_bundle import expected_bundle


class SourceCells(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.cells=[];self.cell=None

    def handle_starttag(self,tag,attrs):
        if tag in ('td','th'):self.cell={'attrs':dict(attrs),'text':''}
        elif self.cell is not None and tag=='br':self.cell['text']+='\n'

    def handle_endtag(self,tag):
        if tag in ('td','th') and self.cell is not None:
            self.cells.append(self.cell);self.cell=None

    def handle_data(self,data):
        if self.cell is not None:self.cell['text']+=data


def extract_sources(html):
    parser=SourceCells();parser.feed(html)
    sources={};current=None
    for cell in parser.cells:
        classes=cell['attrs'].get('class','').split()
        if 'linecontent' in classes and cell['text'].strip().lower().endswith('.sas'):
            current=cell['text'].strip().replace('\xa0',' ')
            if current in sources:raise AssertionError('Repeated source-path heading: '+current)
            sources[current]=[]
        elif current and 'data' in classes and '#edf2f9' in cell['attrs'].get('style','').lower():
            sources[current].append(cell['text'])
    return sources


EXPECTED={
    'CopyPreviewA.sas':[
        '%macro CopyPreviewA(value=3);','data work.mp_copied_a;','value=&value;',
        'label="A < B & C > D";','run;','%mend;','',
        '/* Demo: run after the definition. */','%CopyPreviewA(value=7);'],
    'CopyPreviewB.sas':[
        '%macro CopyPreviewB;','data work.mp_copied_b;','length note $40;',
        'note=\'It\'\'s a <test> & "quote"\';','flag=1;','flag=1;','run;',
        '%mend;','','/* Demo: preserve quotes, blank lines and repeated statements. */','%CopyPreviewB;']}


def validate_fixture(html):
    sources=extract_sources(html)
    assert len(sources)==2,('Expected two macro sections',list(sources))
    copied=[]
    for path,lines in sources.items():
        name=path.replace('\\','/').rsplit('/',1)[-1]
        # A tab-only cell represents a blank source line. Copy it unchanged;
        # never repair nonbreaking spaces in copied code to make a test pass.
        assert ['' if not line.strip() else line for line in lines]==EXPECTED[name],(name,lines)
        assert all('\xa0' not in line for line in lines),'Copied source contains nonbreaking spaces'
        copied.extend(lines)
    assert '#00008b' in html.lower() and '#edf2f9' in html.lower(),'Original colors missing'
    assert 'align="left"' in html.lower() or 'text-align: left' in html.lower(),'Report not left aligned'
    return '\n'.join(copied)+'\n'


class MacroparasHTMLTests(unittest.TestCase):
    @staticmethod
    def fixture_html():
        cells=[]
        for name,lines in EXPECTED.items():
            cells.append('<td class="linecontent">/Macros/'+name+'</td>')
            cells.extend('<td class="data" style="background-color:#edf2f9;color:#00008b">'+escape(line if line else '\t')+'</td>' for line in lines)
        return '<table align="left">'+''.join(cells)+'</table>'

    def test_loader_bundle_is_current(self):
        loader=(ROOT/'MCPDeps/importallmacros_ue.sas').read_text()
        portable=(ROOT/'examples/sas_macros/macroparas_portable.sas').read_text()
        self.assertEqual(loader,expected_bundle(loader,portable))

    def test_explicit_import_resolves_self_contained_loader(self):
        import tempfile
        with tempfile.TemporaryDirectory() as folder,patch('pathlib.Path.cwd',return_value=Path(folder)),patch.dict('os.environ',{'SAS_ODA_AUTOLOAD_MACROS':'0'}):
            plan=Plan('%importallmacros_ue();')
        self.assertIn(ROOT/'MCPDeps/importallmacros_ue.sas',plan.macros)
        self.assertNotIn('InstallGitHubZipPackage',plan.remote_macros)
        self.assertIn('macroparas',plan.definitions)

    def test_global_bootstrap_is_transferred_only_when_requested(self):
        import tempfile
        with tempfile.TemporaryDirectory() as folder,patch('pathlib.Path.cwd',return_value=Path(folder)):
            with patch.dict('os.environ',{'SAS_ODA_AUTOLOAD_MACROS':'0'}):
                self.assertEqual(Plan('proc print data=sashelp.class;run;').files,{})
            with patch.dict('os.environ',{'SAS_ODA_AUTOLOAD_MACROS':'1'}):
                plan=Plan('proc print data=sashelp.class;run;')
            code,manifest=plan.prepare(Path(folder),'/home/test')
        self.assertEqual(list(plan.files),['importallmacros_ue.sas'])
        self.assertEqual(len(manifest),1)
        self.assertTrue(manifest[0]['skip_if_same'])
        self.assertNotIn('%importallmacros_ue(',code) # Backend owns explicit bootstrap.

    def test_rendered_fixture_rejects_added_line_numbers(self):
        html=self.fixture_html().replace('%macro CopyPreviewA','1 %macro CopyPreviewA',1)
        with self.assertRaises(AssertionError):validate_fixture(html)

    def test_fixture_extracts_without_source_repairs(self):
        copied=validate_fixture(self.fixture_html())
        self.assertIn('label="A < B & C > D";',copied)
        self.assertEqual(copied.count('flag=1;'),2)
        self.assertIn('%CopyPreviewA(value=7);',copied)
        self.assertIn('\n\t\n',copied)

    def test_rejects_nonbreaking_spaces_inside_quoted_values(self):
        html=self.fixture_html().replace('A &lt; B','A&#160;&lt; B',1)
        with self.assertRaises(AssertionError):validate_fixture(html)


if __name__=='__main__':
    if '--html' in sys.argv:
        p=argparse.ArgumentParser(description=__doc__)
        p.add_argument('--html',type=Path,required=True)
        p.add_argument('--write-copied',type=Path)
        args=p.parse_args()
        copied=validate_fixture(args.html.read_text(encoding='utf-8',errors='strict'))
        if args.write_copied:args.write_copied.write_text(copied,encoding='utf-8',newline='\n')
        print('PASS: two path headings, twenty source/demo lines, original colors, left alignment and ordinary spaces.')
    else:unittest.main(verbosity=2)
