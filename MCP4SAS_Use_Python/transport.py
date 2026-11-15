"""Authenticated, bounded JSON RPC to the Python-only SASPy backend.

Separate interpreter process enforces wall-clock timeouts and contains SASPy/Java
output, keeping MCP stdout clean. A named session reuses its own backend only.
"""
import contextlib
import hashlib
import json
import os
from pathlib import Path
import secrets
import socket
import subprocess
import sys
import time
from .tempfiles import pid_alive
from .windows_processes import identity as windows_identity,owned_tree as windows_owned_tree

MAX_FRAME = 256 * 1024 * 1024

def recv_exact(sock,size):
    out=bytearray()
    while len(out)<size:
        part=sock.recv(size-len(out))
        if not part:
            raise EOFError('Backend connection closed before complete response')
        out.extend(part)
    return bytes(out)

def request(port,token,payload,timeout=120,progress=None):
    data=json.dumps(dict(payload,_token=token),ensure_ascii=False).encode('utf-8')
    if len(data)>MAX_FRAME:
        raise ValueError('RPC request exceeds 256 MiB')
    deadline=time.monotonic()+timeout if timeout else None
    with socket.create_connection(('127.0.0.1',port),timeout=min(timeout or 10,10)) as sock:
        sock.sendall(len(data).to_bytes(8,'big')+data)
        while True:
            remaining=deadline-time.monotonic() if deadline else None
            if remaining is not None and remaining<=0:
                raise TimeoutError('SAS operation timed out; user code was not resubmitted')
            sock.settimeout(remaining)
            size=int.from_bytes(recv_exact(sock,8),'big')
            if size>MAX_FRAME:
                raise ValueError('Backend response exceeds 256 MiB')
            response=json.loads(recv_exact(sock,size).decode('utf-8'))
            if response.get('status')=='progress' or response.get('event')=='progress':
                if progress:
                    progress(response)
                continue
            if response.get('status')!='ok':
                raise RuntimeError(response.get('error') or 'SAS backend error')
            return response

def stop_owned_process(process):
    if process.poll() is not None:
        return
    stop_owned_pid(process.pid,process=process)

def stop_owned_pid(pid,grace_seconds=0,process=None):
    grace_seconds=max(0,grace_seconds)
    windows_tree={}
    def process_tree_alive():
        if process is not None:
            process.poll()
        if os.name=='nt':
            return any(windows_identity(child)==stamp for child,stamp in windows_tree.items())
        try:
            os.killpg(pid,0)
            return True
        except ProcessLookupError:
            return False
        except PermissionError:
            return True
    if os.name=='nt':
        if grace_seconds==0:
            subprocess.run(['taskkill.exe','/PID',str(pid),'/T','/F'],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL,check=False)
            return
        try:
            windows_tree=windows_owned_tree(pid)
        except OSError:
            # Keep the established forced tree termination if enumeration is
            # unavailable; do not first kill the root and lose its descendants.
            subprocess.run(['taskkill.exe','/PID',str(pid),'/T','/F'],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL,check=False)
            return
        if pid in windows_tree and windows_identity(pid)==windows_tree[pid]:
            subprocess.run(['taskkill.exe','/PID',str(pid),'/T'],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL,check=False)
        deadline=time.monotonic()+grace_seconds
        while process_tree_alive() and time.monotonic()<deadline:
            time.sleep(max(0,min(.1,deadline-time.monotonic())))
        for child,stamp in windows_tree.items():
            if windows_identity(child)==stamp:
                subprocess.run(['taskkill.exe','/PID',str(child),'/T','/F'],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL,check=False)
    else:
        import signal
        with contextlib.suppress(ProcessLookupError):
            os.killpg(pid,signal.SIGTERM)
        deadline=time.monotonic()+grace_seconds
        while process_tree_alive() and time.monotonic()<deadline:
            time.sleep(max(0,min(.1,deadline-time.monotonic())))
        if process_tree_alive():
            with contextlib.suppress(ProcessLookupError):
                os.killpg(pid,signal.SIGKILL)

@contextlib.contextmanager
def registry_lock(directory,name='startup.lock',timeout=40):
    path=directory/name
    deadline=time.monotonic()+timeout
    while True:
        try:
            fd=os.open(path,os.O_CREAT|os.O_EXCL|os.O_WRONLY,0o600)
            with os.fdopen(fd,'w') as handle:
                handle.write(str(os.getpid()))
            break
        except FileExistsError:
            try:
                owner=int(path.read_text())
                if not pid_alive(owner):
                    path.unlink()
                    continue
            except (OSError,ValueError):
                if time.time()-path.stat().st_mtime>40:
                    path.unlink()
                    continue
            if time.monotonic()>deadline:
                raise TimeoutError('Another Python runner is starting this SAS session')
            time.sleep(.1)
    try:
        yield
    finally:
        path.unlink(missing_ok=True)

class Backend:
    def __init__(self,session_id=None,timeout=3600,env=None,local_home=None,state_dir=None,timeout_grace_seconds=15):
        self.persistent=bool(session_id)
        self.session_id=session_id or 'one_shot_'+secrets.token_hex(8)
        self.timeout=timeout
        self.timeout_grace_seconds=max(0,timeout_grace_seconds)
        self.env=dict(os.environ,**(env or {}))
        self.local_home=local_home
        self.process=None
        self.closed=False
        config=self.env.get('SASPY_CFGFILE','')
        backend_version=hashlib.sha256((Path(__file__).parent/'backend/session_backend.py').read_bytes()).hexdigest()
        connection_env={key:value for key,value in self.env.items() if key.startswith(('SASPY_','MCP4SAS_SASPY_'))}
        signature=hashlib.sha256(json.dumps([str(Path(sys.executable).resolve()),connection_env,config,Path(config).stat().st_mtime_ns if config and Path(config).is_file() else None,self.session_id,local_home,str(Path(__file__).parent.resolve()),backend_version],sort_keys=True).encode()).hexdigest()[:24]
        base=Path(state_dir or self.env.get('MCP4SAS_PYTHON_STATE_DIR') or Path.home()/'.cache/mcp4sas-python')
        self.directory=base/signature
        self.directory.mkdir(parents=True,exist_ok=True,mode=0o700)
        self.record=self.directory/'backend.json'
        self.usage_lock=registry_lock(self.directory,'usage.lock',timeout=timeout or 86400)
        self.usage_lock.__enter__()
        try:
            self._connect()
        except BaseException:
            self.usage_lock.__exit__(*sys.exc_info())
            raise

    def _connect(self):
        with registry_lock(self.directory):
            existing=None
            if self.persistent and self.record.is_file():
                try:
                    existing=json.loads(self.record.read_text())
                    if not pid_alive(existing['pid']):
                        existing=None
                    elif request(existing['port'],existing['token'],dict(cmd='ping'),timeout=3).get('pid')!=existing['pid']:
                        existing=None
                except (OSError,ValueError,RuntimeError,EOFError,KeyError):
                    existing=None
            if existing:
                self.port,self.token=existing['port'],existing['token']
                self.pid=existing['pid']
                self.launcher_pid=existing.get('launcher_pid',self.pid)
            else:
                self._start()

    def _start(self):
        with socket.socket() as probe:
            probe.bind(('127.0.0.1',0))
            self.port=probe.getsockname()[1]
        self.token=secrets.token_hex(32)
        env=dict(self.env,SAS_ODA_SESSION_PORT=str(self.port),MCP4SAS_PYTHON_RPC_TOKEN=self.token,SAS_ODA_SESSION_DEBUG_LOG=str(self.directory/'backend.log'))
        logfile=open(self.directory/'worker.log','ab')
        try:
            self.process=subprocess.Popen([sys.executable,'-u',str(Path(__file__).parent/'backend/session_backend.py')],stdin=subprocess.DEVNULL,stdout=logfile,stderr=logfile,env=env,cwd=os.getcwd(),start_new_session=os.name!='nt',creationflags=subprocess.CREATE_NO_WINDOW if os.name=='nt' else 0)
            self.pid=self.process.pid
            self.launcher_pid=self.process.pid
        finally:
            logfile.close()
        deadline=time.monotonic()+30
        try:
            while time.monotonic()<deadline:
                if self.process.poll() is not None:
                    raise RuntimeError('Python SASPy backend could not start. '+(self.directory/'worker.log').read_text(encoding='utf-8',errors='replace')[-8000:])
                try:
                    response=request(self.port,self.token,dict(cmd='ping'),timeout=1)
                    # A Windows venv launcher can own a different PID from the
                    # interpreter it starts. The private token authenticates this
                    # reply; retain the interpreter PID reported by the backend.
                    if isinstance(response.get('pid'),int) and response.get('server_api_version'):
                        self.pid=response['pid']
                        data=dict(pid=self.pid,launcher_pid=self.launcher_pid,port=self.port,token=self.token)
                        fd=os.open(self.record,os.O_CREAT|os.O_TRUNC|os.O_WRONLY,0o600)
                        with os.fdopen(fd,'w') as handle:
                            json.dump(data,handle)
                        return
                except (OSError,RuntimeError,EOFError):
                    time.sleep(.1)
            raise TimeoutError('Python SASPy backend startup timed out')
        except BaseException:
            stop_owned_process(self.process)
            raise

    def call(self,command,**kwargs):
        payload=dict(cmd=command,session_id=self.session_id,**kwargs)
        if self.local_home:
            payload['local_home']=self.local_home
        try:
            return request(self.port,self.token,payload,timeout=self.timeout)
        except (TimeoutError,socket.timeout):
            # User SAS code may have run partially. Do not replay it.
            stop_owned_pid(self.pid,self.timeout_grace_seconds,process=self.process)
            self.record.unlink(missing_ok=True)
            raise
        except RuntimeError as exc:
            from .diagnostics import classify
            if classify(str(exc))['exit_code'] in (73,74):
                # Discard this unusable bridge only. Do not retry user SAS, and
                # do not disturb another runtime or named session.
                # This session is already unusable. Waiting the ordinary
                # timeout grace cannot recover it and only delays diagnosis.
                stop_owned_pid(self.pid,0,process=self.process)
                self.record.unlink(missing_ok=True)
            raise

    def close(self,force=False):
        if self.closed:
            return
        self.closed=True
        if self.persistent and not force:
            self.usage_lock.__exit__(None,None,None)
            return
        try:
            request(self.port,self.token,dict(cmd='close',session_id=self.session_id),timeout=20)
            request(self.port,self.token,dict(cmd='shutdown'),timeout=3)
        except (OSError,EOFError):
            if pid_alive(self.pid):
                stop_owned_pid(self.pid)
        finally:
            deadline=time.monotonic()+5
            while any(pid_alive(pid) for pid in {self.pid,self.launcher_pid}) and time.monotonic()<deadline:
                if os.name!='nt':
                    with contextlib.suppress(ChildProcessError):
                        os.waitpid(self.pid,os.WNOHANG)
                time.sleep(.05)
            if pid_alive(self.pid) or pid_alive(self.launcher_pid):
                stop_owned_pid(self.launcher_pid)
            if self.process:
                try:
                    self.process.wait(timeout=3)
                except subprocess.TimeoutExpired:
                    stop_owned_process(self.process)
            self.record.unlink(missing_ok=True)
            self.usage_lock.__exit__(None,None,None)

    def __enter__(self):
        return self
    def __exit__(self,*args):
        self.close()
