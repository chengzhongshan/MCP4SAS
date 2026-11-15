"""Owned scratch cleanup only; never remove arbitrary project directories."""
import json
import os
from pathlib import Path
import re
import shutil
import tempfile
import time

def pid_alive(pid):
    if not isinstance(pid,int) or pid <= 0:
        return False
    if os.name == 'nt':
        import ctypes
        from ctypes import wintypes
        kernel = ctypes.WinDLL('kernel32',use_last_error=True)
        kernel.OpenProcess.argtypes = [wintypes.DWORD,wintypes.BOOL,wintypes.DWORD]
        kernel.OpenProcess.restype = wintypes.HANDLE
        kernel.GetExitCodeProcess.argtypes = [wintypes.HANDLE,ctypes.POINTER(wintypes.DWORD)]
        kernel.GetExitCodeProcess.restype = wintypes.BOOL
        kernel.CloseHandle.argtypes = [wintypes.HANDLE]
        kernel.CloseHandle.restype = wintypes.BOOL
        handle = kernel.OpenProcess(0x1000,False,pid)
        if not handle:
            return ctypes.get_last_error() == 5
        try:
            code = wintypes.DWORD()
            if not kernel.GetExitCodeProcess(handle,ctypes.byref(code)):
                return True
            return code.value == 259
        finally:
            kernel.CloseHandle(handle)
    try:
        os.kill(pid,0)
        return True
    except PermissionError:
        return True
    except ProcessLookupError:
        return False

def inspect_owned(path,root):
    path,root = Path(path),Path(root).resolve()
    if path.is_symlink() or path.parent.resolve()!=root or not re.fullmatch(r'\.mcp4sas_work_[A-Za-z0-9_]+',path.name):
        return None
    marker = path/'.mcp4sas-owner.json'
    if marker.is_symlink():
        return None
    try:
        info = json.loads(marker.read_text(encoding='utf-8'))
        if not isinstance(info,dict) or info.get('root')!=str(root) or not isinstance(info.get('pid'),int) or isinstance(info.get('pid'),bool) or info['pid']<=0 or not isinstance(info.get('created'),int) or isinstance(info.get('created'),bool):
            return None
        return path.resolve(),info
    except (OSError,ValueError,TypeError):
        return None

def remove_owned(path,root):
    checked = inspect_owned(path,root)
    if not checked:
        raise ValueError(f'Cannot verify owned scratch directory: {path}')
    shutil.rmtree(checked[0])

class Scratch:
    def __init__(self,root=None,keep=False):
        self.root,self.keep = Path(root or os.getcwd()).resolve(),keep
        self.path = Path(tempfile.mkdtemp(prefix='.mcp4sas_work_',dir=self.root))
        (self.path/'.mcp4sas-owner.json').write_text(json.dumps(dict(root=str(self.root),pid=os.getpid(),created=int(time.time()))),encoding='utf-8')
    def __enter__(self):
        return self.path
    def __exit__(self,*args):
        if not self.keep:
            remove_owned(self.path,self.root)

def cleanup(directory='.',older_than_hours=24,apply=False):
    if older_than_hours < 0:
        raise ValueError('Age must be nonnegative')
    root = Path(directory).resolve(strict=True)
    count = 0
    for path in sorted(root.iterdir()):
        checked = inspect_owned(path,root)
        if not checked:
            continue
        resolved,info = checked
        if time.time()-info['created']<older_than_hours*3600 or pid_alive(info['pid']):
            continue
        print(('Removing: ' if apply else 'Would remove: ')+str(resolved))
        if apply:
            remove_owned(resolved,root)
        count += 1
    print(f'Eligible owned scratch directories: {count}')
    if not apply:
        print('Preview only; use --apply to remove them.')
    return count
