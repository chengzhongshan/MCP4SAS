import hashlib
import importlib.util
import io
from pathlib import Path
import tempfile
import unittest
import zipfile
import subprocess
import os
import sys
import json

spec=importlib.util.spec_from_file_location('mcp4sas_jars',Path(__file__).resolve().parents[1]/'src/sas_jars.py')
jars=importlib.util.module_from_spec(spec);spec.loader.exec_module(jars)

def jar_bytes(label):
    data=io.BytesIO()
    with zipfile.ZipFile(data,'w') as z:z.writestr('META-INF/MANIFEST.MF','Manifest-Version: 1.0\n'+label)
    return data.getvalue()

class SASJarTests(unittest.TestCase):
    def test_real_python_cli_uses_the_selected_environment(self):
        with tempfile.TemporaryDirectory(prefix='SAS download ') as temp:
            root=Path(temp);package=root/'environment/saspy';package.mkdir(parents=True)
            (package/'__init__.py').write_text('# isolated test package; no real SASPy modified\n')
            source=root/'SAS download.zip'
            with zipfile.ZipFile(source,'w') as z:
                for name in jars.NAMES:z.writestr('nested/'+name,jar_bytes(name))
            command=[sys.executable,str(Path(jars.__file__)), '--source',str(source)]
            result=subprocess.run(command,cwd=root,env=dict(os.environ,PYTHONPATH=str(package.parent)),text=True,capture_output=True,timeout=15)
            self.assertEqual(result.returncode,0,result.stderr)
            record=json.loads(result.stdout.split('MCP4SAS_JARS_JSON=')[1])
            self.assertEqual(Path(record['directory']),package/'java/iomclient')
            self.assertEqual(set(record['updated']),set(jars.NAMES))
    def test_nested_official_style_zip_installs_only_three_named_jars(self):
        with tempfile.TemporaryDirectory() as temp:
            source=Path(temp)/'SAS-download.zip';dest=Path(temp)/'selected-saspy/java/iomclient'
            with zipfile.ZipFile(source,'w') as z:
                for name in jars.NAMES:z.writestr('download/subfolder/'+name,jar_bytes(name))
                z.writestr('../outside.txt','must not extract');z.writestr('unrelated.exe','must not run')
            result=jars.install(source,dest)
            self.assertEqual(set(result['updated']),set(jars.NAMES))
            self.assertEqual({p.name for p in dest.iterdir()},set(jars.NAMES))
            self.assertFalse((Path(temp)/'outside.txt').exists())
            for name in jars.NAMES:self.assertEqual(hashlib.sha256((dest/name).read_bytes()).hexdigest(),result['hashes'][name])
            self.assertEqual(jars.install(source,dest)['updated'],[])

    def test_parent_folder_search_and_backup_preserve_original_files(self):
        with tempfile.TemporaryDirectory() as temp:
            folder=Path(temp)/'download/a/b';folder.mkdir(parents=True);dest=Path(temp)/'saspy'
            dest.mkdir();old=jar_bytes('old');(dest/jars.NAMES[0]).write_bytes(old)
            for name in jars.NAMES:(folder/name).write_bytes(jar_bytes(name))
            jars.install(Path(temp)/'download',dest)
            self.assertEqual(next(dest.glob('*.mcp4sas-backup-*')).read_bytes(),old)

    def test_missing_invalid_and_conflicting_files_never_change_destination(self):
        with tempfile.TemporaryDirectory() as temp:
            source=Path(temp)/'download';source.mkdir();dest=Path(temp)/'saspy';dest.mkdir()
            (dest/'keep.txt').write_text('unchanged')
            with self.assertRaisesRegex(ValueError,'Missing'):jars.install(source,dest)
            for name in jars.NAMES:(source/name).write_bytes(jar_bytes(name))
            (source/jars.NAMES[1]).write_text('HTML download error, not a JAR')
            with self.assertRaisesRegex(ValueError,'Not a valid JAR'):jars.install(source,dest)
            (source/jars.NAMES[1]).write_bytes(jar_bytes('valid'))
            nested=source/'nested';nested.mkdir();(nested/jars.NAMES[0]).write_bytes(jar_bytes('different'))
            with self.assertRaisesRegex(ValueError,'Different copies'):jars.install(source,dest)
            self.assertEqual([p.name for p in dest.iterdir()],['keep.txt'])

    def test_managed_static_classpath_is_repaired_without_losing_other_settings(self):
        with tempfile.TemporaryDirectory() as temp:
            source=Path(temp)/'download';source.mkdir()
            for name in jars.NAMES:(source/name).write_bytes(jar_bytes(name))
            package=Path(temp)/'saspy';package.mkdir();config=package/'sascfg_personal.py'
            original=("# Values provisioned by the MCP4SAS installer for this isolated environment.\n"
                      "authkey = 'unchanged-fixture'\n_MCP4SAS_CLASSPATH = 'saspyiom.jar'\n")
            config.write_text(original)
            result=jars.install(source,package/'java/iomclient')
            self.assertTrue(result['managed_classpath_updated'])
            self.assertIn("authkey = 'unchanged-fixture'",config.read_text())
            for name in jars.NAMES:self.assertIn(name,config.read_text())
            self.assertEqual(next(package.glob('sascfg_personal.py.mcp4sas-jar-backup-*')).read_text(),original)
            self.assertFalse(jars.install(source,package/'java/iomclient')['managed_classpath_updated'])

    def test_custom_configuration_is_never_rewritten(self):
        with tempfile.TemporaryDirectory() as temp:
            package=Path(temp)/'saspy';package.mkdir();config=package/'sascfg_personal.py'
            config.write_text("oda = {'classpath': 'my-custom-value'}\n")
            before=config.read_bytes()
            self.assertFalse(jars.refresh_managed_classpath(package/'java/iomclient'))
            self.assertEqual(config.read_bytes(),before)

if __name__=='__main__':unittest.main()
