"""Install three user-obtained SAS encryption JARs into this Python's SASPy.

Select a SAS download ZIP or extracted directory. Nothing is downloaded here.
Only the three named JARs are read; no archive paths or executable code run.
"""
import argparse
import ast
import hashlib
import importlib.util
import io
import json
from pathlib import Path
import os
import tempfile
import subprocess
import sys
import zipfile

NAMES=('sas.rutil.jar','sas.rutil.nls.jar','sastpj.rutil.jar')
LIMIT=32*1024*1024

def refresh_managed_classpath(destination):
    """Repair only the installer's static classpath; never rewrite custom profiles."""
    config=Path(destination).parents[1]/'sascfg_personal.py'
    if not config.is_file():return False
    original=config.read_bytes();source=original.decode('utf8')
    if '# Values provisioned by the MCP4SAS installer for this isolated environment.' not in source:return False
    assignment=next((node for node in ast.parse(source).body if isinstance(node,ast.Assign) and any(isinstance(t,ast.Name) and t.id=='_MCP4SAS_CLASSPATH' for t in node.targets)),None)
    if assignment is None or not isinstance(assignment.value,ast.Constant) or not isinstance(assignment.value.value,str):return False
    windows=os.name=='nt' or sys.platform=='cygwin'
    separator=';' if windows else os.pathsep
    items=assignment.value.value.split(separator)
    for name in NAMES:
        value=str((Path(destination)/name).resolve())
        if sys.platform=='cygwin':value=subprocess.check_output(['cygpath','-w',value],text=True).strip()
        if value not in items:items.append(value)
    value=separator.join(items)
    if value==assignment.value.value:return False
    lines=source.splitlines(keepends=True)
    replacement='_MCP4SAS_CLASSPATH = '+repr(value)+'\n'
    revised=''.join(lines[:assignment.lineno-1])+replacement+''.join(lines[assignment.end_lineno:])
    ast.parse(revised)
    backup=config.with_name(config.name+'.mcp4sas-jar-backup-'+hashlib.sha256(original).hexdigest()[:16])
    if backup.exists() and backup.read_bytes()!=original:raise ValueError('Conflicting configuration backup: '+str(backup))
    if not backup.exists():backup.write_bytes(original)
    fd,temporary=tempfile.mkstemp(prefix='.mcp4sas-config-',dir=config.parent)
    try:
        with os.fdopen(fd,'wb') as stream:stream.write(revised.encode('utf8'))
        os.replace(temporary,config)
    finally:Path(temporary).unlink(missing_ok=True)
    return True

def collect(source):
    source=Path(source)
    found={}
    def add(name,data):
        if name not in NAMES:return
        if not data or len(data)>LIMIT:raise ValueError('Empty or oversized JAR: '+name)
        if not zipfile.is_zipfile(io.BytesIO(data)):raise ValueError('Not a valid JAR/ZIP archive: '+name)
        if name in found and found[name]!=data:raise ValueError('Different copies of '+name+' found. Select a more specific folder or archive.')
        found[name]=data
    if source.is_dir():
        visited=0
        def walk(folder,depth=0):
            nonlocal visited
            if depth>6:return
            for child in sorted(folder.iterdir()):
                visited+=1
                if visited>10000:raise ValueError('Selected folder is too large. Select the extracted SAS download folder.')
                if child.is_symlink():continue
                if child.is_dir():walk(child,depth+1)
                elif child.name in NAMES:
                    if child.stat().st_size>LIMIT:raise ValueError('Oversized JAR: '+child.name)
                    add(child.name,child.read_bytes())
        walk(source)
    elif zipfile.is_zipfile(source):
        with zipfile.ZipFile(source) as archive:
            for entry in archive.infolist():
                name=entry.filename.replace('\\','/').split('/')[-1]
                if name in NAMES:
                    if entry.file_size>LIMIT:raise ValueError('Oversized JAR: '+name)
                    add(name,archive.read(entry))
    else:raise ValueError('Select a SAS-provided ZIP archive or its extracted folder.')
    missing=[name for name in NAMES if name not in found]
    if missing:raise ValueError('Missing '+', '.join(missing)+'. Choose the SAS download containing all three files.')
    return found

def install(source,destination):
    files=collect(source) # Validate everything before modifying the environment.
    destination=Path(destination);destination.mkdir(parents=True,exist_ok=True)
    changes=[]
    for name,data in files.items():
        target=destination/name
        if target.is_file() and target.read_bytes()==data:continue
        if target.exists():
            old=target.read_bytes();digest=hashlib.sha256(old).hexdigest()[:16]
            backup=destination/(name+'.mcp4sas-backup-'+digest)
            if backup.exists() and backup.read_bytes()!=old:raise ValueError('Conflicting backup: '+str(backup))
            if not backup.exists():backup.write_bytes(old)
        fd,temporary=tempfile.mkstemp(prefix='.mcp4sas-jar-',dir=destination)
        try:
            with os.fdopen(fd,'wb') as stream:stream.write(data)
            os.replace(temporary,target)
        finally:Path(temporary).unlink(missing_ok=True)
        changes.append(name)
    classpath_updated=refresh_managed_classpath(destination)
    return dict(directory=str(destination),updated=changes,managed_classpath_updated=classpath_updated,hashes={name:hashlib.sha256((destination/name).read_bytes()).hexdigest() for name in NAMES})

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--source',required=True);a=p.parse_args()
    spec=importlib.util.find_spec('saspy')
    if spec is None or not spec.origin:p.error('SASPy is missing from the selected Python. Complete Quick Setup first.')
    if not spec.submodule_search_locations:p.error('A local file is shadowing the SASPy package. Rename that local saspy.py file, then retry.')
    destination=Path(spec.origin).parent/'java'/'iomclient'
    try:result=install(a.source,destination)
    except (ValueError,OSError,zipfile.BadZipFile,RuntimeError) as error:p.exit(1,'SAS JAR setup: '+str(error)+'\n')
    print('MCP4SAS_JARS_JSON='+json.dumps(result))

if __name__=='__main__':main()
