import hashlib
import json
from pathlib import Path
import re
import shlex
import subprocess
import sys
import tempfile
import unittest
from MCP4SAS_Use_Python.homepage_checks import (AdversarialTests,IncludeLookupTests,
    LogAndLabelsTests,MacroGuardTests,MacroReuseTests)
from MCP4SAS_Use_Python.corpus import validate_corpus,build
from MCP4SAS_Use_Python.demo_catalogs import ROOT,ASSETS,catalog,generate
from MCP4SAS_Use_Python.live_examples import assess
from MCP4SAS_Use_Python.cli import parser as runner_parser

class HomepageDemoTests(unittest.TestCase):
    def test_original_500_task_manifest(self):
        self.assertEqual(validate_corpus(),500)

    def test_all_eight_catalogs_generate_original_programs_and_fixtures(self):
        total=0
        with tempfile.TemporaryDirectory() as temp:
            for batch,expected in enumerate([30,30,30,100,100,100,100,100],1):
                original=catalog(batch)
                generated=generate(batch,Path(temp)/f'batch{batch}')
                self.assertEqual(len(generated),expected)
                for before,after in zip(original,generated):
                    self.assertEqual(before['id'],after['id'])
                    reconstructed=after['sas']
                    for index,path in enumerate(after['fixture_paths'],1):
                        token=f'@FIXTURE_{index}@' if before.get('fixtures') else '@FIXTURE@'
                        reconstructed=reconstructed.replace(Path(path).as_posix(),token)
                    self.assertEqual(reconstructed,before['sas'])
                    self.assertTrue(Path(after['path']).is_file())
                    total+=1
                with self.assertRaises(FileExistsError): generate(batch,Path(temp)/f'batch{batch}')
        self.assertEqual(total,590)

    def test_catalog_source_hashes_match_original_perl_files(self):
        data=json.loads((ASSETS/'example_catalogs.json').read_text(encoding='utf-8'))
        for name,expected in data['source_files'].items():
            self.assertEqual(hashlib.sha256((ROOT/'tests'/name).read_bytes()).hexdigest(),expected)
        data=json.loads((ASSETS/'adversarial_cases.json').read_text(encoding='utf-8'))
        self.assertEqual(hashlib.sha256((ROOT/'tests/new_validation_tasks_001_100.pl').read_bytes()).hexdigest(),data['source_sha256'])

    def test_every_homepage_perl_script_has_a_python_counterpart(self):
        for page in ['README.md','examples/README.md','examples/poc/README.md','docs/poc/README.md','integrations/vscode/README.md']:
            source=(ROOT/page).read_text(encoding='utf-8')
            for name in set(re.findall(r'[A-Za-z0-9_./-]+\.pl\b',source)):
                with self.subTest(page=page,script=name):
                    self.assertTrue((ROOT/name).with_suffix('.py').is_file(),name)

    def test_documented_python_runner_flags_parse_and_links_exist(self):
        count=0
        for page in ['README.md','examples/README.md','examples/poc/README.md','docs/poc/README.md','integrations/vscode/README.md','docs/PYTHON_DEMOS.md']:
            path=ROOT/page
            text=path.read_text(encoding='utf-8')
            for label,target in re.findall(r'\[([^\]]+)\]\(([^)]+)\)',text):
                if target.startswith(('http:','https:','#','mailto:')): continue
                local=target.split('#')[0].split('?')[0]
                with self.subTest(page=page,link=target):
                    self.assertTrue((path.parent/local).exists(),target)
            for body in re.findall(r'```(?:bash|sh|powershell)\n(.*?)\n```',text,re.S):
                for line in body.replace('\\\n',' ').splitlines():
                    tokens=shlex.split(line,comments=True)
                    if 'python' not in tokens: continue
                    index=tokens.index('python')
                    if index+1==len(tokens): continue
                    script=tokens[index+1]
                    if script=='run_sas_codes_or_files_in_ODA.py':
                        with self.subTest(page=page,command=line):
                            runner_parser().parse_args(tokens[index+2:])
                            count+=1
        self.assertGreater(count,25)

    def test_mcp_result_validation_requires_computed_marker_and_log(self):
        case=dict(id='01',name='known',html=False)
        with tempfile.TemporaryDirectory() as temp:
            log=Path(temp)/'output.html.info.txt'
            data=dict(structuredContent=dict(status='COMPLETE',exit_code=0,log_path=str(log),diagnostics={}),isError=False)
            self.assertFalse(assess(case,data,1)['passed'])
            log.write_text('=== SAS Log ===\nMCP30_OK_01\n=== Output ===\n')
            self.assertTrue(assess(case,data,1)['passed'])
            log.write_text('=== SAS Log ===\n12 %put MCP30_OK_01;\n=== Output ===\n')
            self.assertFalse(assess(case,data,1)['passed'])

    def test_pinned_builder_reads_git_objects_not_dirty_worktree(self):
        with tempfile.TemporaryDirectory() as temp:
            root=Path(temp)
            (root/'Macros').mkdir()
            body=''.join(f'%macro demo{i}();%mend;\n' for i in range(200))
            body+=''.join(f'%include "input{i}.sas";\n' for i in range(86))
            body+=''.join(f'x=prxmatch(/case{i}.*/,value);\n' for i in range(7))
            (root/'Macros/all.sas').write_text(body)
            for i in range(7): (root/f'demo{i}.sas').write_text(f'%demo{i}();\n')
            subprocess.run(['git','init','-q',str(root)],check=True)
            subprocess.run(['git','-C',str(root),'add','.'],check=True)
            subprocess.run(['git','-C',str(root),'-c','user.name=Fixture','-c','user.email=fixture@example.invalid','commit','-qm','fixture'],check=True)
            (root/'Macros/all.sas').write_text('uncommitted change')
            data=build(root)
            self.assertEqual(data['generated_task_count'],500)
            self.assertEqual(data['categories'],dict(declaration=200,invocation=200,include=86,prx_boundary=7,demo=7))

if __name__=='__main__':
    unittest.main()
