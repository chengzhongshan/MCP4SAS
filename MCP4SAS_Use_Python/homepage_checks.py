"""Python counterparts of the homepage's regression checks; no SAS login."""
import ast
import contextlib
import io
import json
import os
from pathlib import Path
import re
import tempfile
import time
import unittest
from unittest.mock import Mock,patch
from . import source_analysis as sa,diagnostics
from .dependencies import Plan,targeted_loader
from .tempfiles import inspect_owned,remove_owned

ROOT=Path(__file__).resolve().parents[1]

def adversarial_checks():
    data=json.loads((Path(__file__).parent/'assets/adversarial_cases.json').read_text(encoding='utf-8'))
    count=0
    def check(ok,name):
        nonlocal count
        count+=1
        if not ok: raise AssertionError(f'T{count:03d}: {name}')
    for source,expected,name in data['include_cases']:
        check(sa.include_targets(source)==expected,name)
    for group,function in [('format_cases',sa.format_name_issues),('fileref_cases',sa.fileref_name_issues)]:
        for source,expected,name in data[group]:
            findings=function(source)
            got=findings[0]['line'] if 'source line' in name and findings else len(findings)
            check(got==expected,name)
    for text,warnings,quality,name in data['diagnostic_cases']:
        summary=diagnostics.summarize(text)
        check([summary['warning_count'],summary['data_quality_count']]==[warnings,quality],name)
    with tempfile.TemporaryDirectory() as temp:
        root=Path(temp).resolve()
        marker=dict(pid=os.getpid(),root=str(root),created=int(time.time()))
        def owned(name,value):
            path=root/name;path.mkdir()
            if value is not None:
                (path/'.mcp4sas-owner.json').write_text(json.dumps(value) if isinstance(value,dict) else value,encoding='utf-8')
            return path
        check(not inspect_owned(root/'missing',root),'missing candidate rejected')
        check(not inspect_owned(root,root/'missing-root'),'missing root rejected')
        wrong=owned('ordinary_dir',marker)
        cases=[(wrong,'wrong basename'),(owned('.mcp4sas_work_bad-name',marker),'hyphen suffix'),
               (owned('.mcp4sas_work_nomarker',None),'no marker'),(owned('.mcp4sas_work_badjson','{broken'),'bad JSON'),
               (owned('.mcp4sas_work_array','[]'),'array marker'),
               (owned('.mcp4sas_work_wrongroot',dict(marker,root=str(root/'other'))),'wrong root'),
               (owned('.mcp4sas_work_nopid',{k:v for k,v in marker.items() if k!='pid'}),'no PID'),
               (owned('.mcp4sas_work_textpid',dict(marker,pid='abc')),'text PID'),
               (owned('.mcp4sas_work_negpid',dict(marker,pid=-2)),'negative PID'),
               (owned('.mcp4sas_work_zeropid',dict(marker,pid=0)),'zero PID'),
               (owned('.mcp4sas_work_nocreated',{k:v for k,v in marker.items() if k!='created'}),'no timestamp'),
               (owned('.mcp4sas_work_textcreated',dict(marker,created='today')),'text timestamp')]
        parent=owned('.mcp4sas_work_parent',marker)
        nested=parent/'.mcp4sas_work_nested';nested.mkdir()
        (nested/'.mcp4sas-owner.json').write_text(json.dumps(marker))
        cases.append((nested,'nested scratch'))
        for path,name in cases: check(not inspect_owned(path,root),name)
        valid=owned('.mcp4sas_work_valid',dict(marker,extra='allowed'))
        info=inspect_owned(valid,root)
        for ok,name in [(info is not None,'valid marker'),(info[0]==valid,'canonical path'),
                        (info[1]['pid']==os.getpid(),'PID retained'),(info[1]['root']==str(root),'root retained'),
                        (info[1]['extra']=='allowed','metadata retained')]: check(ok,name)
        try: remove_owned(wrong,root)
        except ValueError: refused=True
        else: refused=False
        check(refused,'refuse unowned removal');check(wrong.is_dir(),'preserve unowned directory')
        remove_owned(valid,root)
        check(True,'owned removal succeeds');check(not valid.exists(),'owned removal deletes')
        link=root/'.mcp4sas_work_link'
        try: link.symlink_to(wrong,target_is_directory=True)
        except OSError:
            # Exercise the guard even when this Windows account cannot create
            # links; Linux/macOS CI additionally exercises a real filesystem link.
            with patch.object(type(link),'is_symlink',return_value=True):
                check(not inspect_owned(link,root),'symlink guard (mocked filesystem capability)')
        else: check(not inspect_owned(link,root),'symlink rejected')
    assert count==100,count
    return count

class LogAndLabelsTests(unittest.TestCase):
    def test_source_echoes_and_runtime_failures(self):
        for text in ['24 %put ERROR: not executed;','MPRINT(TEST): message="ERROR: data";',
                     'SYMBOLGEN: X resolves to ERROR: data','NOTE: ERROR: literal']:
            with self.subTest(text=text): self.assertEqual(diagnostics.classify(text)['exit_code'],0)
        for text in ['ERROR: File WORK.MISSING.DATA does not exist.','ERROR 180-322: Statement is not valid.',
                     'WARNING: Apparent invocation of macro MISSING not resolved.']:
            with self.subTest(text=text): self.assertNotEqual(diagnostics.classify(text)['exit_code'],0)
    def test_jump_labels_do_not_load_macros(self):
        plan=Plan('%macro demo; %goto cleanup; %cleanup: %mend; %demo; %external_test;')
        self.assertNotIn('cleanup',plan.remote_macros)
        self.assertIn('external_test',plan.remote_macros)

class IncludeLookupTests(unittest.TestCase):
    def test_bundled_home_macro_is_found_without_recursive_scan(self):
        with tempfile.TemporaryDirectory() as temp:
            root=Path(temp)
            for directory in ['MCPDeps','DiffGWASDeps']:
                folder=root/directory;folder.mkdir()
                path=folder/(directory+'-test.sas');path.write_text('%put TEST;')
                plan=Plan(f'%include "~/{path.name}";',source_file=root/'main.sas')
                self.assertIn(path.name,plan.files)

def bootstrap_namespace():
    tree=ast.parse((Path(__file__).parent/'backend/session_backend.py').read_text(encoding='utf-8'))
    constant=next(n for n in tree.body if isinstance(n,ast.Assign) and any(isinstance(t,ast.Name) and t.id=='LOAD_MACROS_CODE' for t in n.targets))
    function=next(n for n in tree.body if isinstance(n,ast.FunctionDef) and n.name=='ensure_macros_loaded')
    namespace=dict(time=time,session_macros_loaded={},session_macro_bootstrap_warning={},session_macro_bootstrap_meta={},
                   log_event=Mock(),status_timestamp=lambda:'test-time',artifact_path_for_suffix=lambda suffix:'not-written'+suffix,
                   write_text_artifact=Mock(),submit_with_heartbeat=Mock(return_value={'LOG':''}),MACRO_BOOTSTRAP_TIMEOUT_SECONDS=10)
    exec(compile(ast.Module(body=[constant,function],type_ignores=[]),'<actual bootstrap functions>','exec'),namespace)
    return namespace

class MacroGuardTests(unittest.TestCase):
    def test_bootstrap_names_and_success_cache(self):
        namespace=bootstrap_namespace();code=namespace['LOAD_MACROS_CODE']
        for group in re.findall(r'%global\s+([^;]+);',code,re.I):
            self.assertTrue(all(len(name)<=32 for name in group.split()))
        session=Mock();session.symget.return_value='0'
        with contextlib.redirect_stdout(io.StringIO()):
            namespace['ensure_macros_loaded']('test',session)
        self.assertFalse(namespace['session_macros_loaded']['test'])
        session.symget.side_effect=lambda name:'1' if name=='_pipeline_macro_bootstrap_ok' else '0'
        with contextlib.redirect_stdout(io.StringIO()):
            namespace['ensure_macros_loaded']('test',session)
        self.assertTrue(namespace['session_macros_loaded']['test'])
        self.assertIn('%macro _pipeline_verify_macro_tmp;',targeted_loader(['example']))

class MacroReuseTests(unittest.TestCase):
    def test_verified_bootstrap_is_not_submitted_again(self):
        namespace=bootstrap_namespace();namespace['session_macros_loaded']['test']=True
        self.assertEqual(namespace['ensure_macros_loaded']('test',Mock()),'')
        namespace['submit_with_heartbeat'].assert_not_called()

class AdversarialTests(unittest.TestCase):
    def test_original_100_adversarial_contracts(self):
        self.assertEqual(adversarial_checks(),100)

def checks_main(group):
    groups={'logs':[LogAndLabelsTests],'includes':[IncludeLookupTests],
            'macro_guard':[MacroGuardTests],'macro_reuse':[MacroReuseTests],
            'adversarial':[AdversarialTests]}
    if group=='lifecycle':
        from .tests.test_backend import RealBackendProcessTests
        selected=[RealBackendProcessTests]
    else: selected=groups[group]
    suite=unittest.TestSuite(unittest.defaultTestLoader.loadTestsFromTestCase(cls) for cls in selected)
    return 0 if unittest.TextTestRunner(verbosity=2).run(suite).wasSuccessful() else 1
