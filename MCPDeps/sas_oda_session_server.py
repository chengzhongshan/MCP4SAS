#!/usr/bin/env python3
import socket, threading, json, struct, time, sys, traceback, io, contextlib
from saspy import SASsession
import os
from datetime import datetime
HOST = '127.0.0.1'
PORT = 8765
SERVER_API_VERSION = '2026-07-01-macro-bootstrap-timeout'
sessions = {}
session_macros_loaded = {}
session_macro_bootstrap_warning = {}
session_macro_bootstrap_meta = {}
lock = threading.Lock()
LOG_PATH = os.environ.get('SAS_ODA_SESSION_DEBUG_LOG') or os.path.join(os.path.dirname(__file__), 'sas_oda_session_server.log')
STATUS_FILE = os.environ.get('SAS_ODA_STATUS_FILE') or ''
LOAD_MACROS_CODE = '''
%macro _pipeline_bootstrap_macros;
%global _pipeline_macro_bootstrap_ok;
%let _pipeline_macro_bootstrap_ok=0;
%let _home=%sysfunc(pathname(HOME));
%let _macro_home=&_home/Macros;
%let _pipeline_opt_mprint=%sysfunc(getoption(mprint,keyword));
%let _pipeline_opt_mlogic=%sysfunc(getoption(mlogic,keyword));
%let _pipeline_opt_symbolgen=%sysfunc(getoption(symbolgen,keyword));
%let _pipeline_opt_notes=%sysfunc(getoption(notes,keyword));
%let _pipeline_opt_source=%sysfunc(getoption(source,keyword));
%let _pipeline_opt_source2=%sysfunc(getoption(source2,keyword));
options nomprint nomlogic nosymbolgen nonotes nosource nosource2;
%if %sysfunc(fileexist("&_home/importallmacros_ue.sas")) %then %do;
    %include "&_home/importallmacros_ue.sas";
%end;
%else %if %sysfunc(fileexist("&_macro_home/importallmacros_ue.sas")) %then %do;
    %include "&_macro_home/importallmacros_ue.sas";
%end;
%else %do;
    filename M url "https://raw.githubusercontent.com/chengzhongshan/COVID19_GWAS_Analyzer/main/Macros/importallmacros_ue.sas";
    %include M;
    filename M clear;
%end;
%if %sysmacexist(importallmacros_ue) %then %do;
    %importallmacros_ue(MacroDir=&_macro_home,fileRgx=.,verbose=0);
    %let _pipeline_macro_bootstrap_ok=1;
%end;
options &_pipeline_opt_mprint &_pipeline_opt_mlogic &_pipeline_opt_symbolgen &_pipeline_opt_notes &_pipeline_opt_source &_pipeline_opt_source2;
%put NOTE: PIPELINE_MACRO_BOOTSTRAP_OK=&_pipeline_macro_bootstrap_ok;
%mend;
%_pipeline_bootstrap_macros;
'''
SUBMIT_HEARTBEAT_SECONDS = max(0, int(os.environ.get('SAS_ODA_SUBMIT_HEARTBEAT_SECONDS', '20') or '20'))
MACRO_BOOTSTRAP_TIMEOUT_SECONDS = max(0, int(os.environ.get('SAS_ODA_MACRO_BOOTSTRAP_TIMEOUT_SECONDS', '420') or '420'))
def iter_saspy_cfg_names(cfgfile=None):
    explicit = os.environ.get('SASPY_CFGNAME') or os.environ.get('SASPY_CONFIG_NAME')
    preferred = explicit or 'oda'
    seen = set()
    names = (preferred,) if cfgfile else (preferred, 'oda', 'default')
    for name in names:
        if not name or name in seen:
            continue
        seen.add(name)
        yield name

def saspy_cfgfile():
    for key in ('SASPY_CFGFILE', 'SASPY_CONFIG_FILE'):
        value = os.environ.get(key)
        if value and os.path.isfile(os.path.expanduser(value)):
            return os.path.expanduser(value)
    return None

def read_fd_capture(fd):
    chunks = []
    try:
        while True:
            chunk = os.read(fd, 8192)
            if not chunk:
                break
            chunks.append(chunk)
    except Exception:
        pass
    return b''.join(chunks).decode('utf-8', errors='replace')

def start_sas_session(**kwargs):
    captured = io.StringIO()
    fd_output = ''
    saved_stdout = saved_stderr = None
    out_r = err_r = None
    try:
        saved_stdout = os.dup(1)
        saved_stderr = os.dup(2)
        out_r, out_w = os.pipe()
        err_r, err_w = os.pipe()
        os.dup2(out_w, 1)
        os.dup2(err_w, 2)
        os.close(out_w)
        os.close(err_w)
        try:
            with contextlib.redirect_stdout(captured), contextlib.redirect_stderr(captured):
                return SASsession(**kwargs)
        finally:
            os.dup2(saved_stdout, 1)
            os.dup2(saved_stderr, 2)
            os.close(saved_stdout)
            os.close(saved_stderr)
            saved_stdout = saved_stderr = None
            fd_output = (read_fd_capture(out_r) + read_fd_capture(err_r)).strip()
            os.close(out_r)
            os.close(err_r)
            out_r = err_r = None
    except Exception as exc:
        detail = "\n".join(part for part in (captured.getvalue().strip(), fd_output) if part)
        if detail:
            raise RuntimeError(f"{exc}\nSASPy/Java output:\n{detail}") from exc
        raise
    finally:
        for saved_fd, target_fd in ((saved_stdout, 1), (saved_stderr, 2)):
            if saved_fd is not None:
                try:
                    os.dup2(saved_fd, target_fd)
                    os.close(saved_fd)
                except Exception:
                    pass
        for read_fd in (out_r, err_r):
            if read_fd is not None:
                try:
                    os.close(read_fd)
                except Exception:
                    pass

def open_sas_session():
    last_exc = None
    cfgfile = saspy_cfgfile()
    for cfgname in iter_saspy_cfg_names(cfgfile):
        try:
            kwargs = {'cfgname': cfgname, 'results': 'html', 'prompt': False}
            if cfgfile:
                kwargs['cfgfile'] = cfgfile
            return start_sas_session(**kwargs)
        except Exception as exc:
            last_exc = exc
    if last_exc is not None:
        try:
            kwargs = {'results': 'html', 'prompt': False}
            if cfgfile:
                kwargs['cfgfile'] = cfgfile
            return start_sas_session(**kwargs)
        except Exception:
            raise last_exc
    kwargs = {'results': 'html', 'prompt': False}
    if cfgfile:
        kwargs['cfgfile'] = cfgfile
    return start_sas_session(**kwargs)
def log_event(message):
    stamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    line = f"[{stamp}] {message}\n"
    try:
        with open(LOG_PATH, 'a', encoding='utf-8') as fh:
            fh.write(line)
    except Exception:
        pass

def status_timestamp():
    return time.strftime('%Y-%m-%d %H:%M:%S', time.localtime())

def artifact_path_for_suffix(suffix):
    if STATUS_FILE and STATUS_FILE.endswith('.run.status.json'):
        return STATUS_FILE[:-len('.run.status.json')] + suffix
    base_dir = os.path.dirname(STATUS_FILE) if STATUS_FILE else os.getcwd()
    return os.path.join(base_dir or os.getcwd(), suffix.lstrip('.'))

def _coerce_epoch(value):
    if value is None:
        return None
    if isinstance(value, (int, float)):
        return int(value)
    text = str(value).strip()
    if not text:
        return None
    text = ' '.join(text.split())
    for fmt in (
        '%d%b%Y:%H:%M:%S',
        '%d%b%Y:%H:%M',
        '%d%b%Y %H:%M:%S',
        '%d%b%Y %H:%M',
        '%Y-%m-%d %H:%M:%S',
        '%Y-%m-%d %H:%M',
        '%m/%d/%Y %H:%M:%S',
        '%m/%d/%Y %H:%M',
        '%a, %d %b %Y %H:%M:%S',
    ):
        try:
            return int(datetime.strptime(text, fmt).timestamp())
        except Exception:
            pass
    try:
        return int(datetime.fromisoformat(text).timestamp())
    except Exception:
        return None

def _local_file_metadata(local_path):
    stat = os.stat(local_path)
    created_epoch = None
    modified_epoch = None
    try:
        created_epoch = int(os.path.getctime(local_path))
    except Exception:
        pass
    try:
        modified_epoch = int(os.path.getmtime(local_path))
    except Exception:
        pass
    return {
        'size': int(stat.st_size),
        'created_epoch': created_epoch,
        'modified_epoch': modified_epoch,
    }

def _remote_file_matches_local_upload(remote_info, local_path):
    if not isinstance(remote_info, dict) or not remote_info.get('exists'):
        return False
    try:
        local_meta = _local_file_metadata(local_path)
    except Exception:
        return False
    remote_size = remote_info.get('size')
    if remote_size is None:
        return False
    try:
        if int(remote_size) != int(local_meta.get('size') or 0):
            return False
    except Exception:
        return False
    remote_epochs = []
    local_epochs = []
    for key in ('created_epoch', 'modified_epoch'):
        value = remote_info.get(key)
        if value is not None:
            try:
                remote_epochs.append(int(value))
            except Exception:
                pass
        local_value = local_meta.get(key)
        if local_value is not None:
            try:
                local_epochs.append(int(local_value))
            except Exception:
                pass
    if not remote_epochs or not local_epochs:
        return False
    for remote_epoch in remote_epochs:
        for local_epoch in local_epochs:
            if abs(remote_epoch - local_epoch) <= 2:
                return True
    return False

def write_text_artifact(path, text):
    if not path:
        return
    try:
        os.makedirs(os.path.dirname(path), exist_ok=True)
    except Exception:
        pass
    with open(path, 'w', encoding='utf-8') as fh:
        fh.write(text or '')
def create_session(session_id):
    log_event(f"create_session start session_id={session_id}")
    sess = open_sas_session()
    session_macros_loaded[session_id] = False
    session_macro_bootstrap_warning[session_id] = False
    session_macro_bootstrap_meta[session_id] = {}
    log_event(f"create_session done session_id={session_id}")
    return sess

def ensure_macros_loaded(session_id, sess):
    if session_macros_loaded.get(session_id):
        return ''
    log_event(f"macro_bootstrap start session_id={session_id}")
    bootstrap_started_at = status_timestamp()
    bootstrap_started_epoch = time.time()
    bootstrap_log_path = artifact_path_for_suffix(f'.macro_bootstrap.{session_id or "default"}.log.txt')
    write_text_artifact(
        bootstrap_log_path,
        "\n".join([
            f"Session ID: {session_id}",
            f"Bootstrap Start: {bootstrap_started_at}",
            "Bootstrap End: ",
            "Elapsed Seconds: ",
            "Bootstrap OK: ",
            "Warning: ",
            "Status: running",
            "",
            "=== SAS Macro Bootstrap Log ===",
            "",
        ])
    )
    print(f"[{session_id}] SAS ODA macro bootstrap started at {bootstrap_started_at}", flush=True)
    res = submit_with_heartbeat(
        sess,
        LOAD_MACROS_CODE,
        session_id,
        label="SAS ODA macro bootstrap",
        timeout_seconds=MACRO_BOOTSTRAP_TIMEOUT_SECONDS,
    )
    macro_log = res.get('LOG', '')
    bootstrap_ok = ''
    try:
        bootstrap_ok = str(sess.symget('_pipeline_macro_bootstrap_ok') or '').strip()
    except Exception:
        bootstrap_ok = ''
    if not bootstrap_ok and 'PIPELINE_MACRO_BOOTSTRAP_OK=1' in macro_log:
        bootstrap_ok = '1'
    warning = bootstrap_ok != '1'
    bootstrap_finished_at = status_timestamp()
    bootstrap_elapsed_seconds = round(time.time() - bootstrap_started_epoch, 2)
    write_text_artifact(
        bootstrap_log_path,
        "\n".join([
            f"Session ID: {session_id}",
            f"Bootstrap Start: {bootstrap_started_at}",
            f"Bootstrap End: {bootstrap_finished_at}",
            f"Elapsed Seconds: {bootstrap_elapsed_seconds}",
            f"Bootstrap OK: {bootstrap_ok or '0'}",
            f"Warning: {1 if warning else 0}",
            "",
            "=== SAS Macro Bootstrap Log ===",
            macro_log or '',
        ]) + "\n"
    )
    session_macro_bootstrap_meta[session_id] = {
        'started_at': bootstrap_started_at,
        'finished_at': bootstrap_finished_at,
        'elapsed_seconds': bootstrap_elapsed_seconds,
        'ok': bootstrap_ok or '0',
        'warning': bool(warning),
        'log_path': bootstrap_log_path,
    }
    print(
        f"[{session_id}] SAS ODA macro bootstrap finished at {bootstrap_finished_at} "
        f"(elapsed {bootstrap_elapsed_seconds}s, ok={bootstrap_ok or '0'})",
        flush=True,
    )
    print(f"[{session_id}] Bootstrap-only SAS log saved to: {bootstrap_log_path}", flush=True)
    session_macro_bootstrap_warning[session_id] = warning
    if warning:
        print(f"[{session_id}] WARNING: Macro load may have failed - check log above", flush=True)
        log_event(f"macro_bootstrap warning session_id={session_id}")
    session_macros_loaded[session_id] = True
    log_event(f"macro_bootstrap done session_id={session_id}")
    return macro_log

def env_truthy(value):
    return str(value or '').strip().lower() in ('1', 'true', 'yes', 'y', 'on')

def format_elapsed(seconds):
    seconds = max(0, int(seconds or 0))
    hrs, rem = divmod(seconds, 3600)
    mins, secs = divmod(rem, 60)
    if hrs:
        return f"{hrs}h {mins}m {secs}s"
    if mins:
        return f"{mins}m {secs}s"
    return f"{secs}s"

def print_submit_heartbeat(label, elapsed_seconds):
    sys.stderr.write(f"{label} is still running in SAS ODA... elapsed {format_elapsed(elapsed_seconds)}\n")
    sys.stderr.flush()

def submit_with_heartbeat(sess, sas_code, session_id, label=None, timeout_seconds=None):
    display_label = f"{label or 'SAS ODA job'} [{session_id}]"
    if SUBMIT_HEARTBEAT_SECONDS <= 0:
        return sess.submit(sas_code)

    holder = {}
    done = threading.Event()

    def _worker():
        try:
            holder['res'] = sess.submit(sas_code)
        except BaseException as exc:
            holder['err'] = exc
            holder['tb'] = traceback.format_exc()
        finally:
            done.set()

    worker = threading.Thread(target=_worker, daemon=True)
    worker.start()

    start = time.time()
    last_heartbeat = start
    while not done.wait(1.0):
        now = time.time()
        if timeout_seconds and now - start >= timeout_seconds:
            log_event(f"submit timeout label={display_label} session_id={session_id} elapsed={int(now - start)}s")
            raise TimeoutError(
                f"{display_label} timed out after {int(timeout_seconds)}s. "
                "The local SASPy/IOM bridge may still be blocked inside SAS ODA and will be restarted."
            )
        if now - last_heartbeat >= SUBMIT_HEARTBEAT_SECONDS:
            print_submit_heartbeat(display_label, now - start)
            log_event(f"submit heartbeat label={display_label} session_id={session_id} elapsed={int(now - start)}s")
            last_heartbeat = now

    worker.join()
    if 'err' in holder:
        detail = holder.get('tb') or repr(holder['err'])
        raise RuntimeError(detail)
    return holder.get('res', {})

def ensure_session(session_id):
    if session_id not in sessions:
        with lock:
            if session_id not in sessions:
                log_event(f"ensure_session create_missing session_id={session_id}")
                sess = create_session(session_id)
                sessions[session_id] = sess
    else:
        log_event(f"ensure_session reuse session_id={session_id}")
    return sessions[session_id]

def session_home(sess):
    sess.submit("%let homepath=%sysfunc(pathname(HOME));")
    return sess.symget('homepath')

def resolve_remote_path(remote_path, sess):
    if remote_path.startswith('~/'):
        remote_path = f"{session_home(sess)}/{remote_path[2:]}"
    return remote_path

def join_remote_path(remote_dir, remote_file):
    remote_dir = str(remote_dir or '')
    remote_file = str(remote_file or '')
    if remote_dir in ('', '.'):
        return remote_file
    if remote_dir == '/':
        return f"/{remote_file.lstrip('/')}"
    return f"{remote_dir.rstrip('/')}/{remote_file.lstrip('/')}"

def normalize_delete_target(remote_file, remote_dir, sess):
    remote_file = str(remote_file or '')
    remote_dir = str(remote_dir or '')
    if remote_file.startswith('~/') or remote_file.startswith('/'):
        remote_path = resolve_remote_path(remote_file, sess)
        return os.path.basename(remote_path), os.path.dirname(remote_path) or '/'
    if not remote_dir or str(remote_dir).strip() in ('', '.'):
        return remote_file, session_home(sess)
    if str(remote_dir).strip() == '~':
        return remote_file, session_home(sess)
    if remote_dir.startswith('~/'):
        return remote_file, resolve_remote_path(remote_dir, sess)
    return remote_file, remote_dir

def run_fileinfo(sess, remote_path):
    remote_path = resolve_remote_path(remote_path, sess)
    safe_path = remote_path.replace('"', '""')
    sas_code = f"""
    filename myfile "{safe_path}";
    data _null_;
        length _size $64 _created $128 _modified $128;
        fid = fopen('myfile','I',1,'B');
        if fid > 0 then do;
            _size = compress(finfo(fid,'File Size (bytes)'));
            if missing(_size) then _size = compress(finfo(fid,'File Size'));
            _created = strip(finfo(fid,'Create Time'));
            if missing(_created) then _created = strip(finfo(fid,'Created'));
            _modified = strip(finfo(fid,'Last Modified'));
            if missing(_modified) then _modified = strip(finfo(fid,'Last Modified Time'));
            if missing(_modified) then _modified = strip(finfo(fid,'Modification Time'));
            call symputx('_remote_exists','1','G');
            call symputx('_remote_size', _size, 'G');
            call symputx('_remote_created', _created, 'G');
            call symputx('_remote_modified', _modified, 'G');
            rc = fclose(fid);
        end;
        else do;
            call symputx('_remote_exists','0','G');
            call symputx('_remote_size', '', 'G');
            call symputx('_remote_created', '', 'G');
            call symputx('_remote_modified', '', 'G');
        end;
    run;
    """
    sess.submit(sas_code)
    exists = sess.symget('_remote_exists')
    size = sess.symget('_remote_size')
    created = sess.symget('_remote_created')
    modified = sess.symget('_remote_modified')
    size_val = int(size) if size and str(size).isdigit() else None
    created = str(created).strip() if created is not None and str(created).strip() else None
    modified = str(modified).strip() if modified is not None and str(modified).strip() else None
    return {
        'exists': (exists == '1') or (size_val is not None),
        'size': size_val,
        'path': remote_path,
        'created': created,
        'modified': modified,
        'created_epoch': _coerce_epoch(created),
        'modified_epoch': _coerce_epoch(modified),
    }

def run_delete(sess, remote_file, remote_dir):
    remote_file, remote_dir = normalize_delete_target(remote_file, remote_dir, sess)
    remote_path = join_remote_path(remote_dir, remote_file)
    safe_path = remote_path.replace('"', '""')
    sas_code = f"""
    filename myfile "{safe_path}";
    data _null_;
        rc = fdelete("myfile");
    run;
    """
    return sess.submit(sas_code)

def print_upload_progress(label, transferred, total, done=False):
    total = max(int(total or 0), 1)
    transferred = max(0, min(int(transferred or 0), total))
    pct = int((transferred * 100) / total)
    bar_width = 24
    filled = min(bar_width, int((pct * bar_width) / 100))
    bar = '#' * filled + '-' * (bar_width - filled)
    msg = f"{label} [{bar}] {pct:3d}% ({transferred:,}/{total:,} bytes)"
    stream = sys.stderr
    if done:
        stream.write(msg + "\n")
    else:
        stream.write(msg + "\r")
    stream.flush()

def poll_local_file_progress(local_path, total_size, stop_event, label):
    last_pct = -1
    last_report = 0.0
    try:
        while not stop_event.is_set():
            try:
                size = os.path.getsize(local_path) if os.path.exists(local_path) else 0
                pct = int((size * 100) / max(int(total_size or 1), 1))
                now = time.time()
                if pct != last_pct and (pct >= last_pct + 1 or now - last_report >= 5):
                    print_upload_progress(label, size, total_size, done=False)
                    last_pct = pct
                    last_report = now
            except Exception:
                pass
            stop_event.wait(1.5)
    finally:
        pass

def poll_remote_upload_progress(session_id, remote_path, local_size, stop_event, label=None):
    poll_sess = None
    last_pct = -1
    last_report = 0.0
    progress_label = label or f"Upload progress [{session_id}]"
    try:
        while not stop_event.is_set():
            try:
                if poll_sess is None:
                    poll_sess = open_sas_session()
                info = run_fileinfo(poll_sess, remote_path)
                size = info.get('size') or 0
                pct = int((size * 100) / max(int(local_size or 1), 1))
                now = time.time()
                if pct != last_pct and (pct >= last_pct + 1 or now - last_report >= 5):
                    print_upload_progress(progress_label, size, local_size, done=False)
                    last_pct = pct
                    last_report = now
            except Exception:
                pass
            stop_event.wait(3.0)
    finally:
        try:
            if poll_sess is not None:
                poll_sess.endsas()
        except Exception:
            pass

def submit_result_has_visible_content(res):
    if not isinstance(res, dict):
        return False
    log = str(res.get('LOG', '') or '')
    lst = str(res.get('LST', '') or '')
    return bool(log.strip() or lst.strip())

def probe_session_after_empty_submit(sess):
    try:
        probe = sess.submit("%put PIPELINE_POST_SUBMIT_PING;")
        probe_log = str((probe or {}).get('LOG', '') or '')
        if 'PIPELINE_POST_SUBMIT_PING' in probe_log:
            return True, ''
        probe_lst = str((probe or {}).get('LST', '') or '')
        if probe_log.strip() or probe_lst.strip():
            return True, probe_log or probe_lst
        return False, 'Probe submit after empty result also returned no visible log/listing content.'
    except BaseException as exc:
        detail = traceback.format_exc()
        return False, f"{type(exc).__name__}: {exc}\n{detail}"

def with_retry(session_id, fn):
    try:
        sess = ensure_session(session_id)
        return fn(sess)
    except Exception as e:
        err = str(e)
        log_event(f"with_retry error session_id={session_id} err={err}")
        if 'No SAS process attached' in err or 'SAS process has terminated' in err:
            with lock:
                log_event(f"with_retry recreating session_id={session_id}")
                sess = create_session(session_id)
                sessions[session_id] = sess
            return fn(sess)
        raise
def handle_client(conn, addr):
    try:
        hdr = conn.recv(8)
        if not hdr:
            return
        n = int.from_bytes(hdr, 'big')
        data = b''
        while len(data) < n:
            chunk = conn.recv(n - len(data))
            if not chunk:
                break
            data += chunk
        req = json.loads(data.decode('utf-8'))
        cmd = req.get('cmd')
        session_id = req.get('session_id')
        log_event(f"request cmd={cmd} session_id={session_id} from={addr[0]}:{addr[1]}")
        if cmd == 'ping':
            resp = {'status':'ok', 'server_api_version': SERVER_API_VERSION, 'pid': os.getpid()}
        elif cmd == 'shutdown':
            resp = {'status':'ok', 'msg':'shutting_down', 'server_api_version': SERVER_API_VERSION, 'pid': os.getpid()}
            out = json.dumps(resp).encode('utf-8')
            conn.sendall(len(out).to_bytes(8,'big') + out)
            log_event("shutdown requested")
            def _exit_soon():
                time.sleep(0.2)
                os._exit(0)
            threading.Thread(target=_exit_soon, daemon=True).start()
            return
        elif cmd == 'create':
            with lock:
                if session_id in sessions:
                    resp = {'status':'ok', 'msg':'exists'}
                    log_event(f"create exists session_id={session_id}")
                else:
                    try:
                        create_started = time.time()
                        sess = create_session(session_id)
                        sessions[session_id] = sess
                        create_elapsed_seconds = round(time.time() - create_started, 2)
                        resp = {'status':'ok', 'msg':'created', 'macro_log':'', 'create_elapsed_seconds':create_elapsed_seconds}
                        log_event(f"create created session_id={session_id} elapsed={create_elapsed_seconds}s")
                    except Exception as e:
                        resp = {'status':'error','error':f"Session create failed: {str(e)}"}
                        log_event(f"create error session_id={session_id} err={e}")
        elif cmd == 'submit':
            try:
                load_macros = req.get('load_macros')
                if load_macros is None:
                    load_macros = env_truthy(os.environ.get('SAS_ODA_AUTOLOAD_MACROS', '1'))
                macro_log = ''
                macro_warning = False
                macro_meta = {}
                def _submit(sess):
                    nonlocal macro_log, macro_warning, macro_meta
                    if load_macros:
                        bootstrap_ran = not bool(session_macros_loaded.get(session_id, False))
                        macro_log = ensure_macros_loaded(session_id, sess) or ''
                        if bootstrap_ran:
                            macro_warning = bool(session_macro_bootstrap_warning.get(session_id, False))
                            macro_meta = dict(session_macro_bootstrap_meta.get(session_id, {}) or {})
                    res = submit_with_heartbeat(sess, req.get('code',''), session_id, label="SAS ODA user job")
                    if not submit_result_has_visible_content(res):
                        alive, probe_detail = probe_session_after_empty_submit(sess)
                        if not alive:
                            raise RuntimeError("SAS submit returned empty output and the SAS session was no longer usable afterwards.\n" + probe_detail)
                    return res
                res = with_retry(session_id, _submit)
                log = str(res.get('LOG',''))
                lst = str(res.get('LST',''))
                if macro_log and macro_warning:
                    log = "=== SAS ODA Macro Bootstrap Log ===\n" + str(macro_log) + "\n=== End SAS ODA Macro Bootstrap Log ===\n\n" + log
                resp = {'status':'ok','log':log,'lst':lst,'macro_bootstrap_meta':macro_meta}
            except Exception as e:
                # try to include recent server-side debug log tail for better diagnostics
                tail = ''
                try:
                    with open(LOG_PATH, 'r', encoding='utf-8') as fh:
                        content = fh.read()
                        if content:
                            lines = content.splitlines()
                            tail = '\n'.join(lines[-300:])
                except Exception:
                    tail = ''
                resp = {'status':'error','error':str(e), 'server_log_tail': tail}
                log_event(f"submit error session_id={session_id} err={e}")
        elif cmd == 'upload':
            local_path = req.get('local_path', '')
            progress_label = req.get('progress_label') or ''
            skip_if_same = req.get('skip_if_same', True)
            try:
                def _upload(sess):
                    log_event(f"upload start session_id={session_id} local_path={local_path} progress_label={progress_label} skip_if_same={skip_if_same}")
                    home = session_home(sess)
                    remote_name = os.path.basename(local_path.replace('\\', '/'))
                    remote_path = f"{home}/{remote_name}"
                    local_size = os.path.getsize(local_path)
                    display_label = progress_label or f"upload: {remote_name}"
                    progress_line_label = f"Upload progress [{display_label}]"
                    if skip_if_same:
                        try:
                            existing_info = run_fileinfo(sess, remote_path)
                        except Exception:
                            existing_info = None
                        if _remote_file_matches_local_upload(existing_info, local_path):
                            print(
                                f"Upload step [{session_id}]: {display_label} -> {remote_path} already matches local size/timestamp; skipping upload.",
                                flush=True,
                            )
                            log_event(f"upload skipped session_id={session_id} remote_path={remote_path} reason=matched_size_timestamp")
                            return remote_path
                    print(f"Upload step [{session_id}]: {display_label} -> {remote_path} ({local_size:,} bytes)", flush=True)
                    stop_event = threading.Event()
                    poller = None
                    try:
                        if local_size >= 10 * 1024 * 1024:
                            print_upload_progress(progress_line_label, 0, local_size, done=False)
                            poller = threading.Thread(
                                target=poll_remote_upload_progress,
                                args=(session_id, remote_path, local_size, stop_event, progress_line_label),
                                daemon=True,
                            )
                            poller.start()
                        sess.upload(local_path, remote_path)
                    finally:
                        stop_event.set()
                        if poller is not None:
                            poller.join(timeout=5)
                    try:
                        info = run_fileinfo(sess, remote_path)
                        final_size = info.get('size') or local_size
                    except Exception:
                        final_size = local_size
                    print_upload_progress(progress_line_label, final_size, local_size, done=True)
                    log_event(f"upload done session_id={session_id} remote_path={remote_path}")
                    return remote_path
                remote_path = with_retry(session_id, _upload)
                resp = {'status':'ok','remote_path':remote_path}
            except Exception as e:
                resp = {'status':'error','error':str(e)}
                log_event(f"upload error session_id={session_id} local_path={local_path} err={e}")
        elif cmd == 'download':
            remote_path = req.get('remote_path', '')
            local_path = req.get('local_path', '')
            try:
                def _download(sess):
                    log_event(f"download start session_id={session_id} remote_path={remote_path} local_path={local_path}")
                    out_path = local_path or os.path.basename(remote_path)
                    out_path = os.path.abspath(out_path)
                    out_dir = os.path.dirname(out_path)
                    if out_dir and not os.path.exists(out_dir):
                        os.makedirs(out_dir, exist_ok=True)
                    remote_info = run_fileinfo(sess, remote_path)
                    if not isinstance(remote_info, dict) or not remote_info.get('exists'):
                        raise FileNotFoundError(f"Remote file does not exist in SAS ODA: {remote_path}")
                    remote_path = remote_info.get('path') or remote_path
                    remote_size = remote_info.get('size') or 0
                    stop_event = threading.Event()
                    poller = None
                    try:
                        if remote_size >= 10 * 1024 * 1024:
                            print_upload_progress(f"Download progress [{session_id}]", 0, remote_size, done=False)
                            poller = threading.Thread(
                                target=poll_local_file_progress,
                                args=(out_path, remote_size, stop_event, f"Download progress [{session_id}]"),
                                daemon=True,
                            )
                            poller.start()
                        sess.download(out_path, remote_path)
                    finally:
                        stop_event.set()
                        if poller is not None:
                            poller.join(timeout=5)
                    if not os.path.exists(out_path):
                        raise FileNotFoundError(f"Download returned without creating local file: {out_path}")
                    final_size = os.path.getsize(out_path)
                    if remote_size > 0 and final_size <= 0:
                        raise IOError(f"Downloaded local file is empty despite non-empty remote file: {out_path}")
                    if remote_size >= 10 * 1024 * 1024:
                        print_upload_progress(f"Download progress [{session_id}]", final_size, remote_size, done=True)
                    log_event(f"download done session_id={session_id} local_path={out_path}")
                    return out_path
                saved_path = with_retry(session_id, _download)
                resp = {'status':'ok','local_path':saved_path}
            except Exception as e:
                resp = {'status':'error','error':str(e)}
                log_event(f"download error session_id={session_id} remote_path={remote_path} err={e}")
        elif cmd == 'delete':
            remote_file = req.get('remote_file', '')
            remote_dir = req.get('remote_dir', '')
            try:
                log_event(f"delete start session_id={session_id} remote_file={remote_file} remote_dir={remote_dir}")
                with_retry(session_id, lambda sess: run_delete(sess, remote_file, remote_dir))
                resp = {'status':'ok','msg':f'delete attempted for {remote_file}'}
                log_event(f"delete done session_id={session_id} remote_file={remote_file}")
            except Exception as e:
                resp = {'status':'error','error':str(e)}
                log_event(f"delete error session_id={session_id} remote_file={remote_file} err={e}")
        elif cmd == 'dirlist':
            remote_path = req.get('remote_path', '')
            try:
                log_event(f"dirlist start session_id={session_id} remote_path={remote_path}")
                files = with_retry(session_id, lambda sess: sess.dirlist(remote_path))
                resp = {'status':'ok','files':files}
            except Exception as e:
                resp = {'status':'error','error':str(e)}
                log_event(f"dirlist error session_id={session_id} remote_path={remote_path} err={e}")
        elif cmd == 'fileinfo':
            remote_path = req.get('remote_path', '')
            try:
                log_event(f"fileinfo start session_id={session_id} remote_path={remote_path}")
                info = with_retry(session_id, lambda sess: run_fileinfo(sess, remote_path))
                resp = {'status':'ok','info':info}
            except Exception as e:
                resp = {'status':'error','error':str(e)}
                log_event(f"fileinfo error session_id={session_id} remote_path={remote_path} err={e}")
        elif cmd == 'gethome':
            try:
                log_event(f"gethome start session_id={session_id}")
                home = with_retry(session_id, session_home)
                resp = {'status':'ok','home':home}
            except Exception as e:
                resp = {'status':'error','error':str(e)}
                log_event(f"gethome error session_id={session_id} err={e}")
            else:
                log_event(f"gethome done session_id={session_id} home={home}")
        else:
            resp = {'status':'error','error':'unknown command'}
            log_event(f"unknown command session_id={session_id} cmd={cmd}")
        out = json.dumps(resp).encode('utf-8')
        conn.sendall(len(out).to_bytes(8,'big') + out)
        log_event(f"response status={resp.get('status')} cmd={cmd} session_id={session_id}")
    except Exception as e:
        log_event(f"handle_client fatal err={e}")
        try:
            out = json.dumps({'status':'error','error':str(e)}).encode('utf-8')
            conn.sendall(len(out).to_bytes(8,'big') + out)
        except Exception:
            pass
    finally:
        conn.close()
def server_loop():
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        s.bind((HOST, PORT))
        s.listen()
        print(f"SAS ODA session server listening on {HOST}:{PORT}", flush=True)
        log_event(f"server_loop listening host={HOST} port={PORT}")
        while True:
            conn, addr = s.accept()
            t = threading.Thread(target=handle_client, args=(conn, addr), daemon=True)
            t.start()
if __name__ == '__main__':
    server_loop()
