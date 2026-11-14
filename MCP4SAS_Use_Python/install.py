#!/usr/bin/env python3
"""Configure this Python runtime; never download proprietary SAS encryption files."""
import argparse
import importlib.util
import json
import os
from pathlib import Path
import shutil
import sys

HERE=Path(__file__).resolve().parent
ROOT=HERE.parent
JARS=('sas.rutil.jar','sas.rutil.nls.jar','sastpj.rutil.jar')

def java_path():
    candidates=[os.environ.get('SASPY_JAVA_WIN'),os.environ.get('SASPY_JAVA')]
    if os.environ.get('JAVA_HOME'):
        candidates.extend(str(Path(os.environ['JAVA_HOME'])/'bin'/name) for name in ('java.exe','java'))
    if os.name=='nt':
        programfiles=Path(os.environ.get('ProgramFiles','C:/Program Files'))
        for vendor in ('Microsoft','Eclipse Adoptium','Java'):
            candidates.extend(str(p) for p in (programfiles/vendor).glob('*/bin/java.exe'))
        candidates.extend(str(p) for p in programfiles.glob('SASHome/SASPrivateJavaRuntimeEnvironment/*/jre/bin/java.exe'))
    else:
        candidates.extend(['/opt/homebrew/opt/openjdk/bin/java','/usr/local/opt/openjdk/bin/java','/usr/bin/java'])
    candidates.append(shutil.which('java'))
    return next((str(Path(p).resolve()) for p in candidates if p and Path(p).is_file()),None)

def jar_directory(explicit=None):
    import saspy
    if explicit:
        directory=Path(explicit).expanduser().resolve()
        missing=[name for name in JARS if not (directory/name).is_file()]
        if missing:
            raise ValueError('Missing SAS JARs: '+', '.join(missing)+'. Download/extract from https://support.sas.com/downloads/package.htm?pid=2494')
        return directory
    candidates=[Path(saspy.__file__).parent/'java/iomclient',Path(sys.base_prefix)/'Lib/site-packages/saspy/java/iomclient',Path.home()/'sas-iom-encryption-jars',Path.home()/'anaconda3/Lib/site-packages/saspy/java/iomclient']
    for path in candidates:
        if all((path/name).is_file() for name in JARS):
            return path.resolve()
    return None

def configure(jars=None,check=False):
    for package in ('saspy','mcp'):
        if importlib.util.find_spec(package) is None:
            raise ValueError('Missing '+package+': run this Python with -m pip install -r '+str(HERE/'requirements.txt'))
    java=java_path()
    directory=jar_directory(jars or os.environ.get('MCP4SAS_SASPY_IOM_DIR'))
    result=dict(python=sys.executable,java=java,encryption_jars_found=bool(directory),jars_directory=str(directory) if directory else None,sas_oda_port=8591,credentials_configured=any((Path.home()/name).is_file() for name in ('_authinfo','.authinfo')),sas_connection_tested=False)
    if check:
        return result
    if not java:
        raise ValueError('Java was not found. Install a Windows JDK, macOS OpenJDK, or Ubuntu default-jre; then rerun.')
    if not directory:
        raise ValueError('SAS ODA needs three encryption JARs from SAS: https://support.sas.com/downloads/package.htm?pid=2494 . Download/extract them and use --jars-dir FOLDER.')
    config_dir=HERE/'.saspy-config'
    # Windows inherits the project's ACL so VS Code and native Python can both
    # read this credential-free config; mode 0700 has special ACL semantics in
    # Python 3.13+ and can isolate files created by a restricted setup process.
    config_dir.mkdir(exist_ok=True,mode=0o777 if os.name=='nt' else 0o700)
    config=config_dir/'sascfg_personal.py'
    prefix='import os\n'+f'os.environ.setdefault("MCP4SAS_SASPY_IOM_DIR", {str(directory)!r})\n'+f'os.environ.setdefault("SASPY_JAVA", {java!r})\n'
    if os.name=='nt':
        prefix+=f'os.environ.setdefault("SASPY_JAVA_WIN", {java!r})\n'
    # The original tracked config template contains no account credentials.
    template=(ROOT/'install/sascfg_personal.template.py').read_text(encoding='utf-8')
    fd=os.open(config,os.O_CREAT|os.O_TRUNC|os.O_WRONLY,0o600)
    with os.fdopen(fd,'w',encoding='utf-8',newline='\n') as handle:
        handle.write(prefix+'\n'+template)
    result['config_file']=str(config)
    return result

def main(argv=None):
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--jars-dir')
    parser.add_argument('--check',action='store_true',help='Report installed prerequisites without writing configuration or connecting.')
    args=parser.parse_args(argv)
    try:
        print(json.dumps(configure(args.jars_dir,args.check),indent=2))
        return 0
    except (OSError,ValueError) as exc:
        print(str(exc),file=sys.stderr)
        return 1

if __name__=='__main__':
    raise SystemExit(main())
