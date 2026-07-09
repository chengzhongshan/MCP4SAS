package SAS_ODA_Runner;

BEGIN {
    require File::Basename;
    require File::Spec;
    if (!$ENV{HOME}) {
        my $cwd_home = eval {
            require Cwd;
            Cwd::abs_path('.');
        } || '';
        if (defined $cwd_home && length $cwd_home) {
            $ENV{HOME} = $cwd_home;
        }
        elsif (defined $ENV{USERPROFILE} && length $ENV{USERPROFILE}) {
            $ENV{HOME} = $ENV{USERPROFILE};
        }
        elsif (defined $ENV{HOMEDRIVE} && defined $ENV{HOMEPATH} && length($ENV{HOMEDRIVE} . $ENV{HOMEPATH})) {
            $ENV{HOME} = $ENV{HOMEDRIVE} . $ENV{HOMEPATH};
        }
    }
    my $deps_dir = File::Basename::dirname(__FILE__);
    my @roots = ($deps_dir, File::Spec->catdir($deps_dir, File::Spec->updir()));
    my $python_site_for = sub {
        my ($python_bin) = @_;
        return '' unless defined $python_bin && length $python_bin;
        my $probe = 'import importlib.util, sysconfig; '
          . 'spec = importlib.util.find_spec("saspy"); '
          . 'print(sysconfig.get_path("purelib") if spec else "")';
        my $pid = open my $fh, '-|', $python_bin, '-c', $probe;
        return '' unless $pid;
        my $site = <$fh>;
        close $fh;
        return '' unless defined $site;
        chomp $site;
        return -d $site ? $site : '';
    };
    my $append_fallback_python_bins = sub {
        my ($bins_ref) = @_;
        my $perl_bin_dir = eval { File::Basename::dirname($^X) } || '';
        if ($perl_bin_dir && -d $perl_bin_dir) {
            push @{$bins_ref}, sort glob(File::Spec->catfile($perl_bin_dir, 'python*.exe'));
            push @{$bins_ref},
              File::Spec->catfile($perl_bin_dir, 'python3'),
              File::Spec->catfile($perl_bin_dir, 'python');
        }
        if (defined $ENV{USERPROFILE} && length $ENV{USERPROFILE}) {
            push @{$bins_ref}, File::Spec->catfile($ENV{USERPROFILE}, 'anaconda3', 'python.exe');
        }
        push @{$bins_ref}, 'python3', 'python.exe', 'python';
    };
    if (!$ENV{PIPELINE_PYTHON_BIN}) {
        my @python_candidates;
        for my $root (@roots) {
            my $record = File::Spec->catfile($root, '.venv-pipeline', '.python-bin');
            if (-f $record) {
                if (open my $fh, '<', $record) {
                    my $line = <$fh>;
                    close $fh;
                    if (defined $line) {
                        chomp $line;
                        if (length($line) && -x $line) {
                            push @python_candidates, $line;
                        }
                    }
                }
            }
            for my $cand (
                File::Spec->catfile($root, '.venv-pipeline', 'bin', 'python'),
                File::Spec->catfile($root, '.venv-pipeline', 'bin', 'python3'),
                File::Spec->catfile($root, '.venv-pipeline', 'Scripts', 'python.exe'),
                File::Spec->catfile($root, '.venv-pipeline', 'Scripts', 'python')
              )
            {
                push @python_candidates, $cand if -x $cand;
            }
        }
        $append_fallback_python_bins->(\@python_candidates);
        my %seen_python;
        for my $cand (@python_candidates) {
            next unless defined $cand && length $cand;
            next if $seen_python{$cand}++;
            my $site = $python_site_for->($cand);
            next unless $site;
            $ENV{PIPELINE_PYTHON_BIN} = $cand;
            $ENV{PYTHONPATH} = $site unless $ENV{PYTHONPATH};
            last;
        }
    }
    unless ($ENV{PYTHONPATH}) {
        for my $root (@roots) {
            my @site_dirs = (
                glob(File::Spec->catdir($root, '.venv-pipeline', 'lib', 'python*', 'site-packages')),
                File::Spec->catdir($root, '.venv-pipeline', 'lib', 'site-packages'),
                File::Spec->catdir($root, '.venv-pipeline', 'Lib', 'site-packages')
            );
            next unless @site_dirs;
            for my $site (@site_dirs) {
                next unless -d $site;
                $ENV{PYTHONPATH} = $site;
                last;
            }
            last if $ENV{PYTHONPATH};
        }
        if (!$ENV{PYTHONPATH}) {
            my @python_candidates;
            push @python_candidates, $ENV{PIPELINE_PYTHON_BIN}
              if $ENV{PIPELINE_PYTHON_BIN};
            $append_fallback_python_bins->(\@python_candidates);
            my %seen_python;
            for my $cand (@python_candidates) {
                next unless defined $cand && length $cand;
                next if $seen_python{$cand}++;
                my $site = $python_site_for->($cand);
                next unless $site;
                $ENV{PYTHONPATH} = $site;
                $ENV{PIPELINE_PYTHON_BIN} ||= $cand;
                last;
            }
        }
    }
}

use strict;
use warnings;
use Exporter qw(import);
use Cwd qw(getcwd abs_path);
use File::Temp qw(tempfile);
use File::Basename;
use File::Spec;
use JSON::PP qw(encode_json decode_json);
use IO::Socket::INET;
use IO::Select;
my $INLINE_PYTHON_SOURCE = <<'END_PYTHON';
import saspy
import json
import os
import sys
import time
import threading
import traceback
from datetime import datetime

sys.stdout = sys.stderr

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
STATUS_FILE = os.environ.get('SAS_ODA_STATUS_FILE') or ''

def _status_timestamp():
    return time.strftime('%Y-%m-%d %H:%M:%S', time.localtime())

def _artifact_path_for_suffix(suffix):
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

def _write_text_artifact(path, text):
    if not path:
        return
    try:
        os.makedirs(os.path.dirname(path), exist_ok=True)
    except Exception:
        pass
    with open(path, 'w', encoding='utf-8') as fh:
        fh.write(text or '')

def _write_status(update):
    if not STATUS_FILE:
        return
    payload = {}
    try:
        if os.path.exists(STATUS_FILE):
            with open(STATUS_FILE, 'r', encoding='utf-8') as fh:
                raw = fh.read().strip()
                if raw:
                    payload = json.loads(raw)
    except Exception:
        payload = {}
    payload.update(update or {})
    payload['last_update'] = _status_timestamp()
    payload['last_update_epoch'] = int(time.time())
    tmp_path = STATUS_FILE + '.tmp'
    try:
        os.makedirs(os.path.dirname(STATUS_FILE), exist_ok=True)
    except Exception:
        pass
    with open(tmp_path, 'w', encoding='utf-8') as fh:
        json.dump(payload, fh, ensure_ascii=False, sort_keys=True)
    os.replace(tmp_path, STATUS_FILE)

def _iter_saspy_cfg_names():
    preferred = os.environ.get('SASPY_CFGNAME') or os.environ.get('SASPY_CONFIG_NAME') or 'oda'
    seen = set()
    for name in (preferred, 'oda', 'default'):
        if not name or name in seen:
            continue
        seen.add(name)
        yield name

def _open_sas_session():
    last_exc = None
    for cfgname in _iter_saspy_cfg_names():
        try:
            return saspy.SASsession(cfgname=cfgname, results='html')
        except Exception as exc:
            last_exc = exc
    if last_exc is not None:
        try:
            return saspy.SASsession(results='html')
        except Exception:
            raise last_exc
    return saspy.SASsession(results='html')

def _format_elapsed(seconds):
    seconds = max(0, int(seconds or 0))
    hrs, rem = divmod(seconds, 3600)
    mins, secs = divmod(rem, 60)
    if hrs:
        return f"{hrs}h {mins}m {secs}s"
    if mins:
        return f"{mins}m {secs}s"
    return f"{secs}s"

def _print_submit_heartbeat(label, elapsed_seconds):
    stream = sys.stderr
    stream.write(f"{label} is still running in SAS ODA... elapsed {_format_elapsed(elapsed_seconds)}\n")
    stream.flush()
    _write_status({
        'state': 'running',
        'phase': 'submit_heartbeat',
        'message': f"{label} is still running in SAS ODA... elapsed {_format_elapsed(elapsed_seconds)}",
        'elapsed_seconds': int(elapsed_seconds or 0),
    })

def _submit_with_heartbeat(sess, sas_code, label="SAS ODA job"):
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
    while not done.wait(2.0):
        now = time.time()
        if now - last_heartbeat >= SUBMIT_HEARTBEAT_SECONDS:
            _print_submit_heartbeat(label, now - start)
            last_heartbeat = now

    worker.join()
    if 'err' in holder:
        detail = holder.get('tb') or repr(holder['err'])
        raise RuntimeError(detail)
    return holder.get('res', {})

def _env_truthy(value):
    return str(value or '').strip().lower() in ('1', 'true', 'yes', 'y', 'on')

def get_session(session_obj):
    if session_obj is None or not hasattr(session_obj, '_session'):
        session_obj = type('SessionWrapper', (), {})()
        session_obj._session = _open_sas_session()
        session_obj._macros_loaded = False

    return session_obj._session, session_obj

def ensure_macros_loaded(session_obj):
    session, session_obj = get_session(session_obj)
    if getattr(session_obj, '_macros_loaded', False):
        return session, session_obj

    bootstrap_started_at = _status_timestamp()
    bootstrap_started_epoch = time.time()
    bootstrap_log_path = _artifact_path_for_suffix('.macro_bootstrap.log.txt')
    _write_text_artifact(
        bootstrap_log_path,
        "\n".join([
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
    _write_status({
        'state': 'running',
        'phase': 'macro_bootstrap_start',
        'message': f'SAS ODA macro bootstrap started at {bootstrap_started_at}',
        'bootstrap_started_at': bootstrap_started_at,
        'bootstrap_log_path': bootstrap_log_path,
    })
    sys.stderr.write(f"SAS ODA macro bootstrap started at {bootstrap_started_at}\n")
    sys.stderr.flush()
    res = _submit_with_heartbeat(session, LOAD_MACROS_CODE, "SAS ODA macro bootstrap")
    log = res.get('LOG', '')
    bootstrap_ok = ''
    try:
        bootstrap_ok = str(session.symget('_pipeline_macro_bootstrap_ok') or '').strip()
    except Exception:
        bootstrap_ok = ''
    if not bootstrap_ok and 'PIPELINE_MACRO_BOOTSTRAP_OK=1' in log:
        bootstrap_ok = '1'
    warning = bootstrap_ok != '1'
    bootstrap_finished_at = _status_timestamp()
    bootstrap_elapsed_seconds = round(time.time() - bootstrap_started_epoch, 2)
    _write_text_artifact(
        bootstrap_log_path,
        "\n".join([
            f"Bootstrap Start: {bootstrap_started_at}",
            f"Bootstrap End: {bootstrap_finished_at}",
            f"Elapsed Seconds: {bootstrap_elapsed_seconds}",
            f"Bootstrap OK: {bootstrap_ok or '0'}",
            f"Warning: {1 if warning else 0}",
            "",
            "=== SAS Macro Bootstrap Log ===",
            log or '',
        ]) + "\n"
    )
    _write_status({
        'state': 'running',
        'phase': 'macro_bootstrap_done',
        'message': f'SAS ODA macro bootstrap finished in {bootstrap_elapsed_seconds}s',
        'bootstrap_started_at': bootstrap_started_at,
        'bootstrap_finished_at': bootstrap_finished_at,
        'bootstrap_elapsed_seconds': bootstrap_elapsed_seconds,
        'bootstrap_ok': bootstrap_ok or '0',
        'bootstrap_warning': bool(warning),
        'bootstrap_log_path': bootstrap_log_path,
    })
    sys.stderr.write(
        f"SAS ODA macro bootstrap finished at {bootstrap_finished_at} "
        f"(elapsed {bootstrap_elapsed_seconds}s, ok={bootstrap_ok or '0'})\n"
    )
    sys.stderr.write(f"Bootstrap-only SAS log saved to: {bootstrap_log_path}\n")
    sys.stderr.flush()

    import sys as _sys
    if warning:
        _sys.__stderr__.write("WARNING: Macro load may have failed - check log above\n")

    session_obj._macro_bootstrap_log = log
    session_obj._macro_bootstrap_ok = bootstrap_ok
    session_obj._macro_bootstrap_warning = warning
    session_obj._macro_bootstrap_started_at = bootstrap_started_at
    session_obj._macro_bootstrap_finished_at = bootstrap_finished_at
    session_obj._macro_bootstrap_elapsed_seconds = bootstrap_elapsed_seconds
    session_obj._macro_bootstrap_log_path = bootstrap_log_path
    session_obj._macros_loaded = True
    return session, session_obj

def run_fileinfo(sess, remote_path):
    if remote_path.startswith('~/'):
        sess.submit("%let homepath=%sysfunc(pathname(HOME));")
        home = sess.symget('homepath')
        remote_path = f"{home}/{remote_path[2:]}"
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

def _print_upload_progress(label, transferred, total, done=False):
    total = max(int(total or 0), 1)
    transferred = max(0, min(int(transferred or 0), total))
    pct = int((transferred * 100) / total)
    bar_width = 24
    filled = min(bar_width, int((pct * bar_width) / 100))
    bar = '#' * filled + '-' * (bar_width - filled)
    msg = f"{label} [{bar}] {pct:3d}% ({transferred:,}/{total:,} bytes)"
    stream = sys.stdout
    if done:
        stream.write(msg + "\n")
    else:
        stream.write(msg + "\r")
    stream.flush()
    _write_status({
        'state': 'uploading',
        'phase': 'upload_progress',
        'message': msg,
        'bytes_transferred': int(transferred or 0),
        'bytes_total': int(total or 0),
        'progress_done': bool(done),
    })

def _poll_local_file_progress(local_path, total_size, stop_event, label):
    last_pct = -1
    last_report = 0.0
    try:
        while not stop_event.is_set():
            try:
                size = os.path.getsize(local_path) if os.path.exists(local_path) else 0
                pct = int((size * 100) / max(int(total_size or 1), 1))
                now = time.time()
                if pct != last_pct and (pct >= last_pct + 1 or now - last_report >= 5):
                    _print_upload_progress(label, size, total_size, done=False)
                    last_pct = pct
                    last_report = now
            except Exception:
                pass
            stop_event.wait(1.5)
    finally:
        pass

def _poll_remote_upload_progress(remote_path, local_size, stop_event, label):
    poll_sess = None
    last_pct = -1
    last_report = 0.0
    try:
        while not stop_event.is_set():
            try:
                if poll_sess is None:
                    poll_sess = _open_sas_session()
                info = run_fileinfo(poll_sess, remote_path)
                size = info.get('size') or 0
                pct = int((size * 100) / max(int(local_size or 1), 1))
                now = time.time()
                if pct != last_pct and (pct >= last_pct + 1 or now - last_report >= 5):
                    _print_upload_progress(label, size, local_size, done=False)
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

def _submit_result_has_visible_content(res):
    if not isinstance(res, dict):
        return False
    log = str(res.get('LOG', '') or '')
    lst = str(res.get('LST', '') or '')
    return bool(log.strip() or lst.strip())

def _probe_session_after_empty_submit(session):
    try:
        probe = session.submit("%put PIPELINE_POST_SUBMIT_PING;")
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

def run_sas_logic(sas_code, session_obj):   
    try:    
        macro_log = ''
        macro_warning = False
        _write_status({
            'state': 'running',
            'phase': 'submit_start',
            'message': 'Preparing SAS submit',
        })
        if _env_truthy(os.environ.get('SAS_ODA_AUTOLOAD_MACROS', '1')):
            _write_status({
                'state': 'running',
                'phase': 'macro_bootstrap',
                'message': 'Loading SAS macros from ~/Macros',
            })
            session, session_obj = ensure_macros_loaded(session_obj)
            macro_log = getattr(session_obj, '_macro_bootstrap_log', '') or ''
            macro_warning = bool(getattr(session_obj, '_macro_bootstrap_warning', False))
        else:
            session, session_obj = get_session(session_obj)
        _write_status({
            'state': 'running',
            'phase': 'submit_active',
            'message': 'Submitting SAS program to SAS ODA',
        })
        res = _submit_with_heartbeat(session, sas_code, "SAS ODA job")
        if not _submit_result_has_visible_content(res):
            alive, probe_detail = _probe_session_after_empty_submit(session)
            if not alive:
                return ["ERROR", "SAS submit returned empty output and the SAS session was no longer usable afterwards.\n" + probe_detail, session_obj]
        log = str(res.get('LOG', ''))
        lst = str(res.get('LST', ''))
        if macro_log and macro_warning:
            log = "=== SAS ODA Macro Bootstrap Log ===\n" + str(macro_log) + "\n=== End SAS ODA Macro Bootstrap Log ===\n\n" + log
        _write_status({
            'state': 'running',
            'phase': 'submit_returned',
            'message': 'SAS submit returned to the wrapper',
            'log_length': len(log),
            'listing_length': len(lst),
        })
        return [log, lst, session_obj]
    except BaseException as e:
        detail = traceback.format_exc()
        _write_status({
            'state': 'failed',
            'phase': 'submit_exception',
            'message': f"{type(e).__name__}: {e}",
            'complete': True,
            'success': False,
        })
        return ["ERROR", f"{type(e).__name__}: {e}\n{detail}", session_obj]

def delete_file(remote_file,remote_dir,session_obj):
    remote_file, remote_dir = normalize_delete_target(remote_file, remote_dir, session_obj)
    remote_path = join_remote_path(remote_dir, remote_file)
    safe_path = remote_path.replace('"', '""')
    sas_code = f"""
    filename myfile "{safe_path}";
    data _null_;
        rc = fdelete("myfile");
    run;
    """
    try:
        session, session_obj = get_session(session_obj)
        res=session.submit(sas_code)
        log = str(res.get('LOG', ''))
        lst = str(res.get('LST', ''))
        return f"File deletion attempted for {remote_path}.", session_obj
    except Exception as e:
        return f"PYTHON ERROR : {str(e)}", session_obj

def resolve_remote_path(remote_filepath, session_obj):
    if remote_filepath.startswith('~/'):
        home = get_sas_home(session_obj)[0]
        remote_filepath = f"{home}/{remote_filepath[2:]}"
    return remote_filepath

def join_remote_path(remote_dir, remote_file):
    remote_dir = str(remote_dir or '')
    remote_file = str(remote_file or '')
    if remote_dir in ('', '.'):
        return remote_file
    if remote_dir == '/':
        return f"/{remote_file.lstrip('/')}"
    return f"{remote_dir.rstrip('/')}/{remote_file.lstrip('/')}"

def normalize_delete_target(remote_file, remote_dir, session_obj):
    remote_file = str(remote_file or '')
    remote_dir = str(remote_dir or '')
    if remote_file.startswith('~/') or remote_file.startswith('/'):
        remote_path = resolve_remote_path(remote_file, session_obj)
        remote_dir = os.path.dirname(remote_path) or '/'
        remote_file = os.path.basename(remote_path)
        return remote_file, remote_dir
    if not remote_dir or remote_dir.strip() in ('', '.'):
        remote_dir = get_sas_home(session_obj)[0]
    elif remote_dir.strip() == '~':
        remote_dir = get_sas_home(session_obj)[0]
    elif remote_dir.startswith('~/'):
        remote_dir = resolve_remote_path(remote_dir, session_obj)
    return remote_file, remote_dir

def download_file(remote_filepath, local_path, session_obj):
    try:
        session, session_obj = get_session(session_obj)
        filename = os.path.basename(remote_filepath)
        
        # Logic to handle empty local_path
        if not local_path or local_path.strip() == '':
            local_path = filename # Removed the leading '.' unless you specifically wanted a hidden file
        local_path = os.path.abspath(local_path)
            
        dir_name = os.path.dirname(local_path)

        if dir_name and not os.path.exists(dir_name):
            os.makedirs(dir_name, exist_ok=True)
        remote_info, session_obj = remote_file_info(remote_filepath, session_obj)
        if not isinstance(remote_info, dict) or not remote_info.get('exists'):
            raise FileNotFoundError(f"Remote file does not exist in SAS ODA: {remote_filepath}")
        remote_filepath = remote_info.get('path') or remote_filepath
        remote_size = 0
        if isinstance(remote_info, dict):
            remote_size = remote_info.get('size') or 0
        stop_event = threading.Event()
        poller = None
        try:
            if remote_size >= 10 * 1024 * 1024:
                _print_upload_progress("Download progress", 0, remote_size, done=False)
                poller = threading.Thread(
                    target=_poll_local_file_progress,
                    args=(local_path, remote_size, stop_event, "Download progress"),
                    daemon=True,
                )
                poller.start()
            session.download(local_path, remote_filepath)
        finally:
            stop_event.set()
            if poller is not None:
                poller.join(timeout=5)
        if not os.path.exists(local_path):
            raise FileNotFoundError(f"Download returned without creating local file: {local_path}")
        final_size = os.path.getsize(local_path)
        if remote_size > 0 and final_size <= 0:
            raise IOError(f"Downloaded local file is empty despite non-empty remote file: {local_path}")
        if remote_size >= 10 * 1024 * 1024:
            _print_upload_progress("Download progress", final_size, remote_size, done=True)
        return local_path, session_obj
    except Exception as e:
        # It's good practice to catch or log the error here
        print(f"Download failed: {e}")
        return None, session_obj

def remote_file_info(remote_filepath, session_obj):
    try:
        session, session_obj = get_session(session_obj)
        remote_filepath = resolve_remote_path(remote_filepath, session_obj)
        safe_path = remote_filepath.replace('"', '""')
        sas_code = f'''
        filename myfile "{safe_path}";
        data _null_;
            length _size $64 _exists $8;
            fid = fopen('myfile','I',1,'B');
            if fid > 0 then do;
                _size = compress(finfo(fid,'File Size (bytes)'));
                if missing(_size) then _size = compress(finfo(fid,'File Size'));
                call symputx('_remote_exists','1','G');
                call symputx('_remote_size', _size, 'G');
                rc = fclose(fid);
            end;
            else do;
                call symputx('_remote_exists','0','G');
                call symputx('_remote_size', '', 'G');
            end;
        run;
        '''
        session.submit(sas_code)
        exists = session.symget('_remote_exists')
        size = session.symget('_remote_size')
        size_num = int(size) if size and str(size).strip().isdigit() else None
        exists_flag = (exists == '1') or (size_num is not None)
        return {'exists': exists_flag, 'size': size_num, 'path': remote_filepath}, session_obj
    except Exception as e:
        return f"PYTHON ERROR: {str(e)}", session_obj

def upload_file(local_path, session_obj, progress_label=None, skip_if_same=True):
    try:
        session, session_obj = get_session(session_obj)
        sashomepath = get_sas_home(session_obj)[0]
        remote_name = os.path.basename(local_path.replace('\\', '/'))
        remote_path = f"{sashomepath}/{remote_name}"
        local_size = os.path.getsize(local_path)
        display_label = progress_label or f"dependency upload: {remote_name}"
        progress_line_label = f"Upload progress [{display_label}]"
        if skip_if_same:
            try:
                existing_info = run_fileinfo(session, remote_path)
            except Exception:
                existing_info = None
            if _remote_file_matches_local_upload(existing_info, local_path):
                print(
                    f"Upload step: {display_label} -> {remote_path} already matches local size/timestamp; skipping upload.",
                    flush=True,
                )
                return remote_path, session_obj
        print(f"Upload step: {display_label} -> {remote_path} ({local_size:,} bytes)", flush=True)
        stop_event = threading.Event()
        poller = None
        try:
            if local_size >= 10 * 1024 * 1024:
                _print_upload_progress(progress_line_label, 0, local_size, done=False)
                poller = threading.Thread(
                    target=_poll_remote_upload_progress,
                    args=(remote_path, local_size, stop_event, progress_line_label),
                    daemon=True,
                )
                poller.start()
            session.upload(local_path, remote_path)
        finally:
            stop_event.set()
            if poller is not None:
                poller.join(timeout=5)
        try:
            info = run_fileinfo(session, remote_path)
            final_size = info.get('size') or local_size
        except Exception:
            final_size = local_size
        _print_upload_progress(progress_line_label, final_size, local_size, done=True)
        return remote_path, session_obj
    except Exception as e:
        return f"PYTHON ERROR: {str(e)}", session_obj

import os

def dirlist(remote_path, session_obj):
    try:
        # Get the active session
        session, session_obj = get_session(session_obj)
        
        # listdir returns a list of filenames in the remote_path
        files = session.dirlist(remote_path)
        
        return files, session_obj
    
    except Exception as e:
        return f"PYTHON ERROR: {str(e)}", session_obj

def get_sas_home(session_obj):
    session, session_obj = get_session(session_obj)
    sas_out = session.submit("%let homepath=%sysfunc(pathname(HOME));")
    sashomepath = session.symget('homepath')
    return sashomepath, session_obj

END_PYTHON
;

our @EXPORT_OK = qw(new run_code run_file upload_file download_file);

sub _runner_env_truthy {
    my ($value) = @_;
    return 0 unless defined $value;
    return $value =~ /^(?:1|true|yes|y|on)$/i ? 1 : 0;
}

sub _autoload_macros_enabled {
    return exists $ENV{SAS_ODA_AUTOLOAD_MACROS}
      ? _runner_env_truthy($ENV{SAS_ODA_AUTOLOAD_MACROS})
      : 1;
}

my $SERVER_HOST = '127.0.0.1';
my $SERVER_PORT = 8765;
my $SERVER_API_VERSION = '2026-07-08-submit-progress-frames';
my $SERVER_CONNECT_TIMEOUT_SECONDS = int($ENV{SAS_ODA_SESSION_CONNECT_TIMEOUT_SECONDS} // 5);
my $SERVER_CREATE_TIMEOUT_SECONDS  = int($ENV{SAS_ODA_SESSION_CREATE_TIMEOUT_SECONDS} // 60);
my $SERVER_FILEOP_TIMEOUT_SECONDS  = int($ENV{SAS_ODA_SESSION_FILEOP_TIMEOUT_SECONDS} // 20);
my $SERVER_METADATA_TIMEOUT_SECONDS = int($ENV{SAS_ODA_SESSION_METADATA_TIMEOUT_SECONDS} // 60);
my $SERVER_DELETE_TIMEOUT_SECONDS   = int($ENV{SAS_ODA_SESSION_DELETE_TIMEOUT_SECONDS} // 60);
my $SERVER_GETHOME_TIMEOUT_SECONDS  = int($ENV{SAS_ODA_SESSION_GETHOME_TIMEOUT_SECONDS} // 60);
my $SERVER_UPLOAD_TIMEOUT_SECONDS   = int($ENV{SAS_ODA_SESSION_UPLOAD_TIMEOUT_SECONDS} // 180);
my $SERVER_DOWNLOAD_TIMEOUT_SECONDS = int($ENV{SAS_ODA_SESSION_DOWNLOAD_TIMEOUT_SECONDS} // 180);
my $MACRO_HELPER_UPLOAD_TIMEOUT_SECONDS = int($ENV{SAS_ODA_MACRO_HELPER_UPLOAD_TIMEOUT_SECONDS} // 180);

sub _server_submit_timeout_seconds {
    if (exists $ENV{SAS_ODA_SESSION_SUBMIT_TIMEOUT_SECONDS}) {
        my $explicit = int($ENV{SAS_ODA_SESSION_SUBMIT_TIMEOUT_SECONDS} || 0);
        return $explicit > 0 ? $explicit : 0;
    }

    my $run_timeout = int($ENV{SAS_ODA_RUN_TIMEOUT_SECONDS} || 0);
    return 0 if $run_timeout <= 0;

    my $grace = int($ENV{SAS_ODA_RUN_TIMEOUT_GRACE_SECONDS} || 0);
    $grace = 0 if $grace < 0;
    return $run_timeout + $grace + 60;
}

sub _macro_bootstrap_transport_timeout_seconds {
    my $bootstrap_timeout = int($ENV{SAS_ODA_MACRO_BOOTSTRAP_TIMEOUT_SECONDS} // 420);
    return 0 if $bootstrap_timeout <= 0;

    my $grace = int($ENV{SAS_ODA_MACRO_BOOTSTRAP_RESPONSE_GRACE_SECONDS} // 120);
    $grace = 0 if $grace < 0;
    return $bootstrap_timeout + $grace;
}

sub _effective_persistent_submit_timeout_seconds {
    my (%args) = @_;
    my $load_macros = $args{load_macros} ? 1 : 0;
    my $timeout = _server_submit_timeout_seconds();
    return 0 if $timeout <= 0;

    if ($load_macros) {
        my $macro_timeout = _macro_bootstrap_transport_timeout_seconds();
        $timeout = $macro_timeout if $macro_timeout > $timeout;
    }
    return $timeout;
}

sub _effective_upload_timeout_seconds {
    my (%args) = @_;
    my $requested_timeout = exists $args{timeout_seconds}
      ? int($args{timeout_seconds} || 0)
      : 0;
    return $requested_timeout if $requested_timeout > 0;

    if (!exists $ENV{SAS_ODA_SESSION_UPLOAD_TIMEOUT_SECONDS}) {
        my $run_timeout = int($ENV{SAS_ODA_RUN_TIMEOUT_SECONDS} || 0);
        return 0 if $run_timeout <= 0;
    }

    my $timeout = $SERVER_UPLOAD_TIMEOUT_SECONDS;
    my $local_path = $args{local_path} // '';
    if (length($local_path) && -e $local_path) {
        my $size_bytes = -s $local_path;
        if (defined $size_bytes && $size_bytes > 0) {
            my $size_mb = int(($size_bytes + 1024 * 1024 - 1) / (1024 * 1024));
            my $base_seconds = int($ENV{SAS_ODA_UPLOAD_TIMEOUT_BASE_SECONDS} // 180);
            my $per_mb_seconds = int($ENV{SAS_ODA_UPLOAD_TIMEOUT_SECONDS_PER_MB} // 5);
            $base_seconds = 0 if $base_seconds < 0;
            $per_mb_seconds = 0 if $per_mb_seconds < 0;
            my $size_based_timeout = $base_seconds + ($size_mb * $per_mb_seconds);
            $timeout = $size_based_timeout if $size_based_timeout > $timeout;
        }
    }

    return $timeout > 0 ? $timeout : $SERVER_UPLOAD_TIMEOUT_SECONDS;
}

sub _persistent_direct_upload_threshold_bytes {
    my $threshold = int($ENV{SAS_ODA_PERSISTENT_DIRECT_UPLOAD_THRESHOLD_BYTES} // (10 * 1024 * 1024));
    return $threshold > 0 ? $threshold : 0;
}

sub _should_use_direct_upload_for_persistent_session {
    my ($self, %args) = @_;
    return 0 unless $self->{persistent} && $self->{session_id};

    if (exists $ENV{SAS_ODA_FORCE_DIRECT_UPLOAD}) {
        return _runner_env_truthy($ENV{SAS_ODA_FORCE_DIRECT_UPLOAD}) ? 1 : 0;
    }

    my $threshold = _persistent_direct_upload_threshold_bytes();
    return 0 unless $threshold > 0;

    my $local_path = $args{local_path} // '';
    return 0 unless length($local_path) && -e $local_path;

    my $size_bytes = -s $local_path;
    return 0 unless defined $size_bytes && $size_bytes >= $threshold;

    return 1;
}

# NOTE: This embedded copy is only written to disk when sas_oda_session_server.py
# is missing. Keep it in sync with the standalone sas_oda_session_server.py file.
my $SERVER_PY = <<'END_SERVER_PY';
#!/usr/bin/env python3
import socket, threading, json, struct, time, sys, traceback
from saspy import SASsession
import os
from datetime import datetime
HOST = '127.0.0.1'
PORT = 8765
SERVER_API_VERSION = '2026-07-09-macro-bootstrap-progress-frames'
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
def iter_saspy_cfg_names():
    preferred = os.environ.get('SASPY_CFGNAME') or os.environ.get('SASPY_CONFIG_NAME') or 'oda'
    seen = set()
    for name in (preferred, 'oda', 'default'):
        if not name or name in seen:
            continue
        seen.add(name)
        yield name
def open_sas_session():
    last_exc = None
    for cfgname in iter_saspy_cfg_names():
        try:
            return SASsession(cfgname=cfgname, results='html')
        except Exception as exc:
            last_exc = exc
    if last_exc is not None:
        try:
            return SASsession(results='html')
        except Exception:
            raise last_exc
    return SASsession(results='html')
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

def ensure_macros_loaded(session_id, sess, progress_callback=None):
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
    if callable(progress_callback):
        progress_callback({
            'status': 'progress',
            'kind': 'macro_bootstrap_started',
            'label': 'SAS ODA macro bootstrap',
            'session_id': session_id,
            'started_at': bootstrap_started_at,
        })
    res = submit_with_heartbeat(
        sess,
        LOAD_MACROS_CODE,
        session_id,
        label="SAS ODA macro bootstrap",
        timeout_seconds=MACRO_BOOTSTRAP_TIMEOUT_SECONDS,
        progress_callback=progress_callback,
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
    if callable(progress_callback):
        progress_callback({
            'status': 'progress',
            'kind': 'macro_bootstrap_finished',
            'label': 'SAS ODA macro bootstrap',
            'session_id': session_id,
            'finished_at': bootstrap_finished_at,
            'elapsed_seconds': bootstrap_elapsed_seconds,
            'ok': bootstrap_ok or '0',
            'warning': bool(warning),
        })
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

def send_framed_json(conn, payload):
    out = json.dumps(payload).encode('utf-8')
    conn.sendall(len(out).to_bytes(8, 'big') + out)

def submit_with_heartbeat(sess, sas_code, session_id, label=None, timeout_seconds=None, progress_callback=None):
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
            if callable(progress_callback):
                progress_callback({
                    'status': 'progress',
                    'kind': 'submit_heartbeat',
                    'label': display_label,
                    'session_id': session_id,
                    'elapsed_seconds': int(now - start),
                })
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
                        macro_log = ensure_macros_loaded(
                            session_id,
                            sess,
                            progress_callback=lambda payload: send_framed_json(conn, payload),
                        ) or ''
                        if bootstrap_ran:
                            macro_warning = bool(session_macro_bootstrap_warning.get(session_id, False))
                            macro_meta = dict(session_macro_bootstrap_meta.get(session_id, {}) or {})
                    res = submit_with_heartbeat(
                        sess,
                        req.get('code',''),
                        session_id,
                        label="SAS ODA user job",
                        progress_callback=lambda payload: send_framed_json(conn, payload),
                    )
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
                    if local_size >= 10 * 1024 * 1024:
                        print_upload_progress(progress_line_label, final_size, local_size, done=True)
                    else:
                        print(
                            f"Upload step [{session_id}]: completed {display_label} -> {remote_path} ({final_size:,} bytes)",
                            flush=True,
                        )
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
                    resolved_remote_path = remote_info.get('path') or remote_path
                    remote_size = remote_info.get('size') or 0
                    print(
                        f"Download step [{session_id}]: {resolved_remote_path} -> {out_path} ({remote_size:,} bytes)",
                        flush=True,
                    )
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
                        sess.download(out_path, resolved_remote_path)
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
                    else:
                        print(
                            f"Download step [{session_id}]: saved {out_path} ({final_size:,} bytes)",
                            flush=True,
                        )
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
        send_framed_json(conn, resp)
        log_event(f"response status={resp.get('status')} cmd={cmd} session_id={session_id}")
    except Exception as e:
        log_event(f"handle_client fatal err={e}")
        try:
            send_framed_json(conn, {'status':'error','error':str(e)})
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
END_SERVER_PY

sub _server_reachable {
    my ($host, $port) = @_;
    my $sock = IO::Socket::INET->new(
        PeerAddr => $host,
        PeerPort => $port,
        Proto    => 'tcp',
        Timeout  => ($SERVER_CONNECT_TIMEOUT_SECONDS > 0 ? $SERVER_CONNECT_TIMEOUT_SECONDS : 1),
    );
    return $sock ? 1 : 0;
}

sub _wait_for_server_port_state {
    my ($want_up, $timeout_seconds) = @_;
    my $deadline = time() + (($timeout_seconds && $timeout_seconds > 0) ? $timeout_seconds : 1);
    while (time() <= $deadline) {
        my $up = _server_reachable($SERVER_HOST, $SERVER_PORT) ? 1 : 0;
        return 1 if ($want_up && $up) || (!$want_up && !$up);
        sleep 1;
    }
    return 0;
}

sub _session_server_error_is_transport {
    my ($resp) = @_;
    return 0 unless $resp && ref($resp) eq 'HASH';
    my $error = $resp->{error};
    return 0 unless defined $error && length $error;
    return ($error =~ /(cannot connect to session server|failed to send request to session server|timed out waiting for session server response|timed out after \d+s|failed to read response header from session server|failed to read response body from session server|incomplete response header|incomplete response body|Broken pipe|No SAS process attached|SAS process has terminated unexpectedly)/i) ? 1 : 0;
}

sub _restart_session_server {
    my ($self) = @_;
    $self->{_session_server_ready} = 0 if ref $self;
    my $shutdown = _call_session_server({ cmd => 'shutdown' }, $SERVER_CONNECT_TIMEOUT_SECONDS);
    if (!$shutdown || ($shutdown->{status} // '') ne 'ok') {
        warn "Warning: could not gracefully stop the SAS ODA session server before restart; waiting for the port to clear.\n";
    }
    _wait_for_server_port_state(0, 5);
    $self->_start_server_if_needed();
}

sub _repo_python_env_for_session_server {
    my $module_file = abs_path(__FILE__) || File::Spec->rel2abs(__FILE__);
    $module_file =~ s{\\}{/}g;
    my $module_dir = dirname($module_file);
    my $repo_root = dirname($module_dir);
    my $venv_dir = File::Spec->catdir($repo_root, '.venv-pipeline');
    my $python_bin = $ENV{PIPELINE_PYTHON_BIN} || '';
    my @python_candidates = (
        File::Spec->catfile($venv_dir, 'bin', 'python'),
        File::Spec->catfile($venv_dir, 'bin', 'python3'),
    );
    if (!length($python_bin) && -f File::Spec->catfile($venv_dir, '.python-bin')) {
        if (open(my $py_fh, '<', File::Spec->catfile($venv_dir, '.python-bin'))) {
            chomp($python_bin = <$py_fh> // '');
            close $py_fh;
        }
    }
    for my $candidate (@python_candidates) {
        if (!length($python_bin) && -x $candidate) {
            $python_bin = $candidate;
            last;
        }
    }
    $python_bin = 'python3' unless length $python_bin;

    my @site_candidates = (
        File::Spec->catdir($venv_dir, 'Lib', 'site-packages'),
        glob(File::Spec->catdir($venv_dir, 'lib', 'python*', 'site-packages')),
        File::Spec->catdir($venv_dir, 'lib', 'site-packages'),
    );
    my $site_packages = '';
    for my $candidate (@site_candidates) {
        if (-d $candidate) {
            $site_packages = $candidate;
            last;
        }
    }
    return ($python_bin, $site_packages);
}

sub _prewarm_session_server {
    my ($self) = @_;
    return 1 unless $self->{persistent} && $self->{session_id};
    return 1 if exists $ENV{SAS_ODA_SESSION_PREWARM} && !_runner_env_truthy($ENV{SAS_ODA_SESSION_PREWARM});
    $self->{_prewarm_create_msg} = '';

    my $payload = {
        cmd        => 'create',
        session_id => $self->{session_id},
    };
    my $resp = _call_session_server($payload, $SERVER_CREATE_TIMEOUT_SECONDS);
    if (_session_server_error_is_transport($resp) && !$self->{_prewarm_restart_in_progress}) {
        warn "Warning: SAS ODA session prewarm hit a transport/timeout failure; restarting the local SAS ODA session server and retrying once.\n";
        local $self->{_prewarm_restart_in_progress} = 1;
        $self->_restart_session_server();
        $resp = _call_session_server($payload, $SERVER_CREATE_TIMEOUT_SECONDS);
    }

    if ($resp && ($resp->{status} // '') eq 'ok') {
        my $msg = $resp->{msg} // '';
        $self->{_prewarm_create_msg} = $msg;
        my $elapsed = defined $resp->{create_elapsed_seconds} ? $resp->{create_elapsed_seconds} : undef;
        if (defined $elapsed && length $elapsed) {
            print STDERR "SAS ODA persistent session prewarmed for $self->{session_id} in ${elapsed}s.\n";
        } elsif ($msg eq 'exists') {
            print STDERR "SAS ODA persistent session already warm for $self->{session_id}.\n" if _runner_env_truthy($ENV{SAS_ODA_PREWARM_VERBOSE});
        }
        return 1;
    }

    warn "Warning: SAS ODA session server is reachable, but SAS session prewarm failed for $self->{session_id}: "
       . (($resp && $resp->{error}) ? $resp->{error} : 'unknown error') . "\n";
    $self->{_prewarm_create_msg} = '';
    return 0;
}

sub _call_persistent_session_server {
    my ($self, $payload, $timeout_seconds, $label) = @_;
    $self->_start_server_if_needed();
    my $resp = _call_session_server($payload, $timeout_seconds);
    if ($resp && ($resp->{status} // '') eq 'ok') {
        $self->{_session_server_ready} = 1;
        return $resp;
    }

    if (_session_server_error_is_transport($resp)) {
        warn "Warning: restarting persistent SAS ODA session server after $label transport failure.\n";
        $self->_restart_session_server();
        $resp = _call_session_server($payload, $timeout_seconds);
        $self->{_session_server_ready} = 1 if $resp && ($resp->{status} // '') eq 'ok';
    }

    return $resp;
}

sub _start_server_if_needed {
    my ($self) = @_;
    return unless $self->{persistent} && $self->{session_id};
    $self->{_prewarm_create_msg} = '';
    if ($self->{_session_server_ready}) {
        return if _server_reachable($SERVER_HOST, $SERVER_PORT);
        $self->{_session_server_ready} = 0;
    }
    # If a server is already reachable, make sure it speaks the current
    # protocol/version so file-only operations do not get stuck on an older
    # eager-macro-loading implementation.
    if (_server_reachable($SERVER_HOST, $SERVER_PORT)) {
        my $ping = _call_session_server({ cmd => 'ping' }, $SERVER_CONNECT_TIMEOUT_SECONDS);
        if ($ping && ($ping->{status} // '') eq 'ok' && ($ping->{server_api_version} // '') eq $SERVER_API_VERSION) {
            $self->{_session_server_ready} = 1;
            $self->_prewarm_session_server();
            return;
        }
        if ($ping && ($ping->{status} // '') eq 'ok' && length($ping->{server_api_version} // '')) {
            warn "Warning: restarting stale or incompatible SAS ODA session server on $SERVER_HOST:$SERVER_PORT\n";
            my $shutdown = _call_session_server({ cmd => 'shutdown' }, $SERVER_CONNECT_TIMEOUT_SECONDS);
            if (!$shutdown || ($shutdown->{status} // '') ne 'ok') {
                warn "Warning: could not gracefully stop the stale SAS ODA session server; continuing to wait for the port to clear.\n";
            }
            _wait_for_server_port_state(0, 5);
        } else {
            warn "Warning: SAS ODA session server ping was inconclusive on $SERVER_HOST:$SERVER_PORT; reusing the existing reachable server without forcing a restart.\n";
            $self->{_session_server_ready} = 1;
            $self->_prewarm_session_server();
            return;
        }
    }
    # Refresh the helper script on disk when the embedded server changes so
    # future restarts cannot accidentally relaunch stale Python code.
    my $module_file = abs_path(__FILE__) || File::Spec->rel2abs(__FILE__);
    $module_file =~ s{\\}{/}g;
    my $dir = dirname($module_file);
    my $server_path = File::Spec->catfile($dir, 'sas_oda_session_server.py');
    my $should_write_server = 1;
    if (-e $server_path && open(my $existing_fh, '<', $server_path)) {
        local $/;
        my $existing = <$existing_fh>;
        close $existing_fh;
        $should_write_server = (!defined($existing) || $existing ne $SERVER_PY) ? 1 : 0;
    }
    if ($should_write_server) {
        open my $fh, '>', $server_path or warn "Could not write server file: $server_path: $!" and return;
        print $fh $SERVER_PY;
        close $fh;
        chmod 0755, $server_path;
    }
    # start server in background
    my ($python_bin, $site_packages) = _repo_python_env_for_session_server();
    my $server_stdio_mode = $ENV{SAS_ODA_SERVER_STDIO} // '';
    my $inherit_server_stdio =
      $server_stdio_mode =~ /^(?:1|true|yes|on|inherit|show)$/i ? 1 :
      $server_stdio_mode =~ /^(?:0|false|no|off|silent|hide)$/i ? 0 :
      ((-t STDOUT || -t STDERR) ? 1 : 0);
    my $pid = fork();
    if (!defined $pid) {
        warn "Could not fork SAS ODA session server launcher: $!\n";
        return;
    }
    if ($pid == 0) {
        if (defined($site_packages) && length($site_packages) && -d $site_packages) {
            $ENV{PYTHONPATH} = length($ENV{PYTHONPATH} // '')
              ? "$site_packages:$ENV{PYTHONPATH}"
              : $site_packages;
        }
        $ENV{PIPELINE_PYTHON_BIN} = $python_bin if length $python_bin;
        open STDIN,  '<', File::Spec->devnull();
        unless ($inherit_server_stdio) {
            open STDOUT, '>', File::Spec->devnull();
            open STDERR, '>', File::Spec->devnull();
        }
        exec { $python_bin } $python_bin, $server_path;
        exit 127;
    }
    # wait a short time for server to start
    if (_wait_for_server_port_state(1, 10)) {
        my $ping = _call_session_server({ cmd => 'ping' }, $SERVER_CONNECT_TIMEOUT_SECONDS);
        if ($ping && ($ping->{status} // '') eq 'ok' && ($ping->{server_api_version} // '') eq $SERVER_API_VERSION) {
            $self->{_session_server_ready} = 1;
            $self->_prewarm_session_server();
            return;
        }
    }
    $self->{_session_server_ready} = 0;
    warn "SAS ODA session server did not start after attempts\n";
}

sub _recv_exact_with_timeout {
    my ($sock, $length, $timeout_seconds, $label) = @_;
    my $select = IO::Select->new($sock);
    my $data = '';
    my $started = time();
    my $deadline = ($timeout_seconds && $timeout_seconds > 0) ? time() + $timeout_seconds : 0;
    my $heartbeat_seconds = int($ENV{SAS_ODA_CLIENT_HEARTBEAT_SECONDS} // 20);
    my $last_heartbeat = time();

    while (length($data) < $length) {
        my $wait_seconds;
        if ($deadline) {
            $wait_seconds = $deadline - time();
            return (undef, "timed out waiting for session server response while reading $label")
              if $wait_seconds <= 0;
        }
        my $poll_seconds = defined($wait_seconds)
          ? (($heartbeat_seconds > 0 && $wait_seconds > $heartbeat_seconds) ? $heartbeat_seconds : $wait_seconds)
          : (($heartbeat_seconds > 0) ? $heartbeat_seconds : undef);
        my @ready = defined($poll_seconds) ? $select->can_read($poll_seconds) : $select->can_read();
        unless (@ready) {
            return (undef, "timed out waiting for session server response while reading $label")
              if $deadline && time() >= $deadline;
            if ($heartbeat_seconds > 0 && time() - $last_heartbeat >= $heartbeat_seconds) {
                my $elapsed = int(time() - $started);
                my $timeout_note = $deadline
                  ? sprintf(", timeout=%ds", int($timeout_seconds || 0))
                  : ", timeout=disabled";
                warn "Waiting for SAS ODA session server response while reading $label (elapsed=${elapsed}s$timeout_note)...\n";
                $last_heartbeat = time();
            }
            next;
        }

        my $chunk = '';
        my $got = $sock->recv($chunk, $length - length($data));
        return (undef, "failed to read $label from session server")
          unless defined $got;
        last if $chunk eq '';
        $data .= $chunk;
    }

    return ($data, undef);
}

sub _read_session_server_frame {
    my ($sock, $timeout_seconds) = @_;
    my ($rhdr, $read_hdr_error) = _recv_exact_with_timeout($sock, 8, $timeout_seconds, 'response header');
    return (undef, $read_hdr_error) if $read_hdr_error;
    if (length($rhdr) != 8) {
        return (
            undef,
            {
                status => 'error',
                error  => 'session server returned an incomplete response header',
                raw    => $rhdr,
            }
        );
    }

    my $rlen = unpack('Q>', $rhdr);
    my ($data, $read_body_error) = _recv_exact_with_timeout($sock, $rlen, $timeout_seconds, 'response body');
    return (undef, { status => 'error', error => $read_body_error }) if $read_body_error;
    if (length($data) != $rlen) {
        return (
            undef,
            {
                status => 'error',
                error  => 'session server returned an incomplete response body',
                raw    => $data,
            }
        );
    }

    my $resp;
    eval { $resp = decode_json($data); };
    if ($@) {
        return (undef, { status => 'error', error => "JSON parse error: $@", raw => $data });
    }
    return ($resp, undef);
}

sub _call_session_server {
    my ($payload, $timeout_seconds) = @_;
    my $json = encode_json($payload);
    my $sock = IO::Socket::INET->new(
        PeerAddr => $SERVER_HOST,
        PeerPort => $SERVER_PORT,
        Proto    => 'tcp',
        Timeout  => ($SERVER_CONNECT_TIMEOUT_SECONDS > 0 ? $SERVER_CONNECT_TIMEOUT_SECONDS : 5),
    );
    return { status => 'error', error => 'cannot connect to session server' } unless $sock;
    $sock->autoflush(1);
    # send length-prefixed
    my $len = length($json);
    my $hdr = pack('Q>', $len);
    my $payload_bytes = $hdr . $json;
    my $sent = 0;
    while ($sent < length($payload_bytes)) {
        my $written = $sock->send(substr($payload_bytes, $sent), 0);
        if (!defined $written || $written <= 0) {
            close $sock;
            return { status => 'error', error => 'failed to send request to session server' };
        }
        $sent += $written;
    }
    shutdown($sock, 1);

    my $resp;
    while (1) {
        my ($frame, $frame_error) = _read_session_server_frame($sock, $timeout_seconds);
        if ($frame_error) {
            close $sock;
            return ref($frame_error) eq 'HASH'
              ? $frame_error
              : { status => 'error', error => $frame_error };
        }
        $resp = $frame;
        next if ref($resp) eq 'HASH' && ($resp->{status} // '') eq 'progress';
        last;
    }
    close $sock;
    return $resp;
}

sub _run_nonpersistent_sas_logic_via_python {
    my ($sas_code) = @_;

    my ($codefh, $code_path) = tempfile('sas_inline_code_XXXX', SUFFIX => '.sas', UNLINK => 0, DIR => getcwd());
    print {$codefh} ($sas_code // '');
    close $codefh;

    my ($jsonfh, $json_path) = tempfile('sas_inline_result_XXXX', SUFFIX => '.json', UNLINK => 0, DIR => getcwd());
    close $jsonfh;

    my ($pyfh, $py_path) = tempfile('sas_inline_runner_XXXX', SUFFIX => '.py', UNLINK => 0, DIR => getcwd());
    print {$pyfh} $INLINE_PYTHON_SOURCE;
    print {$pyfh} <<'END_NONPERSISTENT_PY';

def _export_macro_bootstrap_meta(session_obj):
    if session_obj is None:
        return {}
    return {
        'started_at': getattr(session_obj, '_macro_bootstrap_started_at', '') or '',
        'finished_at': getattr(session_obj, '_macro_bootstrap_finished_at', '') or '',
        'elapsed_seconds': getattr(session_obj, '_macro_bootstrap_elapsed_seconds', ''),
        'ok': getattr(session_obj, '_macro_bootstrap_ok', '') or '',
        'warning': bool(getattr(session_obj, '_macro_bootstrap_warning', False)),
        'log_path': getattr(session_obj, '_macro_bootstrap_log_path', '') or '',
    }

def _endsas_safely(session_obj):
    try:
        sess = getattr(session_obj, '_session', None)
        if sess is not None:
            sess.endsas()
    except Exception:
        pass

if __name__ == '__main__':
    code_path = sys.argv[1]
    result_path = sys.argv[2]
    payload = {
        'status': 'error',
        'error': '',
        'log': '',
        'lst': '',
        'macro_bootstrap_meta': {},
    }
    session_obj = None
    try:
        with open(code_path, 'r', encoding='utf-8') as fh:
            sas_code = fh.read()
        res = run_sas_logic(sas_code, session_obj)
        if isinstance(res, (list, tuple)) and len(res) >= 3:
            session_obj = res[2]
        payload['macro_bootstrap_meta'] = _export_macro_bootstrap_meta(session_obj)
        if isinstance(res, (list, tuple)) and len(res) >= 2 and res[0] != "ERROR":
            payload['status'] = 'ok'
            payload['log'] = str(res[0] or '')
            payload['lst'] = str(res[1] or '')
        else:
            payload['error'] = str(res[1] if isinstance(res, (list, tuple)) and len(res) >= 2 else 'unknown error')
    except BaseException as exc:
        payload['error'] = f"{type(exc).__name__}: {exc}\n{traceback.format_exc()}"
    finally:
        _endsas_safely(session_obj)
        with open(result_path, 'w', encoding='utf-8') as fh:
            json.dump(payload, fh, ensure_ascii=False)
END_NONPERSISTENT_PY
    close $pyfh;

    my ($python_bin, $site_packages) = _repo_python_env_for_session_server();
    local $ENV{PIPELINE_PYTHON_BIN} = $python_bin if defined($python_bin) && length($python_bin);
    if (defined($site_packages) && length($site_packages) && -d $site_packages) {
        local $ENV{PYTHONPATH} = length($ENV{PYTHONPATH} // '')
          ? "$site_packages:$ENV{PYTHONPATH}"
          : $site_packages;
        system { $python_bin } $python_bin, $py_path, $code_path, $json_path;
    } else {
        system { $python_bin } $python_bin, $py_path, $code_path, $json_path;
    }

    my $exit_code = $? >> 8;
    my $signal = $? & 127;
    my $result = {};
    if (-e $json_path && open(my $rfh, '<', $json_path)) {
        local $/;
        my $json = <$rfh>;
        close $rfh;
        eval { $result = decode_json($json) if defined $json && length $json; };
        if ($@) {
            $result = {
                status => 'error',
                error  => "Could not parse inline SAS Python result JSON: $@",
            };
        }
    } else {
        $result = {
            status => 'error',
            error  => 'Inline SAS Python helper did not produce a result JSON file.',
        };
    }

    unlink $code_path if defined $code_path && -e $code_path;
    unlink $json_path if defined $json_path && -e $json_path;
    unlink $py_path   if defined $py_path   && -e $py_path;

    if (($exit_code != 0 || $signal != 0) && (!ref($result) || ($result->{status} // '') ne 'ok')) {
        my $detail = $result->{error} // 'unknown inline SAS Python helper failure';
        $detail .= " (exit=$exit_code, signal=$signal)";
        return {
            status => 'error',
            error  => $detail,
            log    => '',
            lst    => '',
        };
    }

    return $result;
}

sub new {
    my ($class, %args) = @_;
    my $requested_persistent = $args{persistent} // 0;
    my $session_id = $args{session_id};
    if (!defined($session_id) || !length($session_id)) {
        $session_id = join('_', 'oneshot', $$, int(time() * 1000), int(rand(1_000_000)));
    }
    my $self = {
        local_macro_dir => $args{local_macro_dir} || "./",
        open_html => $args{open_html} // 1,
        _session => undef,
        _transfer_session => undef,
        persistent => $requested_persistent ? 1 : 0,
        session_id => $session_id,
        requested_persistent => $requested_persistent,
        _prewarm_create_msg => '',
        _session_server_ready => 0,
    };
    return bless $self, $class;
}

sub _dependency_scan_code {
    my ($code) = @_;
    my $scan_code = defined $code ? $code : '';
    # Ignore commented-out demo/example code when auto-detecting local
    # dependencies to upload. This prevents large commented datafile paths
    # from being treated as real runtime inputs.
    $scan_code =~ s{/\*.*?\*/}{}gs;
    $scan_code =~ s{^\s*\*[^;]*;[ \t]*$}{}mg;
    return $scan_code;
}

sub _warn_dependency_upload {
    my (%args) = @_;
    my $kind = $args{kind} // 'dependency';
    my $path = $args{path} // '';
    my $detail = $args{detail} // '';
    my $msg = "WARNING: Auto-uploading $kind detected by internal SAS dependency parsing";
    $msg .= " ($detail)" if length $detail;
    $msg .= ": $path" if length $path;
    $msg .= "\n";
    warn $msg;
}

sub _resolve_local_dependency_path {
    my ($self, $path) = @_;
    return '' unless defined $path && length $path;
    return $path if -e $path;

    my @candidates;
    push @candidates, File::Spec->catfile(getcwd(), $path)
      unless File::Spec->file_name_is_absolute($path);
    push @candidates, File::Spec->catfile($self->{local_macro_dir}, $path)
      if defined($self->{local_macro_dir}) && length($self->{local_macro_dir}) && !File::Spec->file_name_is_absolute($path);

    if ($path =~ m{^(?:~\/|/)} || $path =~ /[\\\/]/) {
        my $base = basename($path);
        if (defined $base && length $base) {
            push @candidates, File::Spec->catfile(getcwd(), $base);
            push @candidates, File::Spec->catfile($self->{local_macro_dir}, $base)
              if defined($self->{local_macro_dir}) && length($self->{local_macro_dir});
        }
    }

    my %seen;
    for my $candidate (@candidates) {
        next unless defined $candidate && length $candidate;
        next if $seen{$candidate}++;
        return $candidate if -e $candidate;
    }
    return '';
}

sub _is_builtin_macro_name {
    my ($name) = @_;
    return 1 unless defined $name && length $name;
    return $name =~ /^(?:let|put|do|else|end|if|then|abort|window|display|str|nrstr|bquote|nrbquote|superq|sysfunc|qsysfunc|scan|substr|upcase|lowcase|length|eval|sysevalf|quote|unquote|cmpres|sysprod|sysmacroname|global|local|mend|macro|goto|return|include)$/i ? 1 : 0;
}

sub _find_local_macro_file {
    my ($self, $macro_name) = @_;
    return unless defined $macro_name && length $macro_name;
    my @bases;
    push @bases, $self->{local_macro_dir}
      if defined $self->{local_macro_dir} && length $self->{local_macro_dir} && -d $self->{local_macro_dir};

    my $module_file = abs_path(__FILE__) || File::Spec->rel2abs(__FILE__);
    $module_file =~ s{\\}{/}g;
    my $module_dir = dirname($module_file);
    push @bases, $module_dir if -d $module_dir;

    my %seen;
    for my $base (@bases) {
        next unless defined $base && length $base;
        next if $seen{$base}++;
        my $direct = File::Spec->catfile($base, "$macro_name.sas");
        return $direct if -e $direct;
    }
    return;
}

sub _local_file_modified_epoch {
    my ($path) = @_;
    return unless defined $path && -e $path;
    my @st = stat($path);
    return $st[9] if @st;
    return;
}

sub _remote_macro_info_candidates {
    my ($self, $macro_name, $local_path) = @_;
    my @remote_paths;
    my $base = defined($local_path) && length($local_path) ? basename($local_path) : '';
    push @remote_paths, "~/Macros/$base" if length $base;
    push @remote_paths, "~/Macros/$macro_name.sas" if defined($macro_name) && length($macro_name);

    my %seen;
    for my $remote_path (@remote_paths) {
        next unless defined $remote_path && length $remote_path;
        next if $seen{lc $remote_path}++;
        my $info = eval { $self->fileinfo($remote_path) };
        next if $@;
        next unless ref($info) eq 'HASH';
        $info->{requested_path} = $remote_path;
        return $info if $info->{exists};
    }
    return;
}

sub _local_macro_should_overlay_remote {
    my ($self, $macro_name, $local_path) = @_;
    my $local_epoch = _local_file_modified_epoch($local_path);
    my $remote_info = $self->_remote_macro_info_candidates($macro_name, $local_path);
    my $remote_path = ref($remote_info) eq 'HASH'
      ? ($remote_info->{requested_path} || $remote_info->{path} || '')
      : ("~/Macros/" . basename($local_path || ''));

    if (ref($remote_info) ne 'HASH' || !$remote_info->{exists}) {
        return (1, "remote macro $remote_path is missing", $remote_info);
    }

    my $remote_epoch = $remote_info->{modified_epoch};
    if (defined($local_epoch) && defined($remote_epoch) && $local_epoch =~ /^\d+$/ && $remote_epoch =~ /^\d+$/) {
        if ($local_epoch > $remote_epoch) {
            return (1, "local macro is newer than $remote_path", $remote_info);
        }
        return (0, "remote macro $remote_path is same age or newer", $remote_info);
    }

    return (1, "could not compare timestamps with $remote_path, overlaying local macro", $remote_info);
}

sub _build_targeted_remote_macro_loader {
    my ($self, $macro_names_ref) = @_;
    return '' unless ref($macro_names_ref) eq 'ARRAY' && @$macro_names_ref;

    my @names = _expanded_targeted_remote_macro_names($macro_names_ref);
    return '' unless @names;

    my $code = <<'SAS';
%let _home=%sysfunc(pathname(HOME));
%let _macro_home=%sysfunc(pathname(HOME))/Macros;
SAS

    for my $name (@names) {
        next unless $name =~ /^[A-Za-z_]\w*$/;
        print STDERR "\nSASPy automatically preparing targeted remote macro loader\n",
                     "either located in the directory ~ (primary choice) or ~/Macros (fallback choice) for: $name\n\n";
        $code .= qq{
%macro _pipeline_load_macro_tmp;
%let _pipeline_targeted_macro_path=;

%if %sysfunc(fileexist("&_home/$name.sas")) %then %do;
    %let _pipeline_targeted_macro_path=&_home/$name.sas;
%end;

%if %length(&_pipeline_targeted_macro_path)=0 %then %do;
    %if %sysfunc(fileexist("&_macro_home/$name.sas")) %then %let _pipeline_targeted_macro_path=&_macro_home/$name.sas;
%end;
%if %length(&_pipeline_targeted_macro_path) > 0 %then %do;
    %include "&_pipeline_targeted_macro_path";
%end;
%mend;
%_pipeline_load_macro_tmp;
};
    }
    return $code;
}

sub _expanded_targeted_remote_macro_names {
    my ($macro_names_ref) = @_;
    return () unless ref($macro_names_ref) eq 'ARRAY' && @$macro_names_ref;

    my %targeted_macro_dependencies = (
        macroparas => [ 'FileOrDirExist', 'del_file_with_fullpath', 'list_files4dsd' ],
    );
    my %seen;
    my @names;
    for my $requested (@$macro_names_ref) {
        next unless defined($requested) && length($requested);
        next if _is_builtin_macro_name($requested);
        my @expanded = (
            @{ $targeted_macro_dependencies{lc $requested} || [] },
            $requested,
        );
        for my $name (@expanded) {
            next unless defined($name) && length($name);
            next if _is_builtin_macro_name($name);
            next if $seen{lc $name}++;
            push @names, $name;
        }
    }
    return @names;
}

sub _find_local_macro_bootstrap_helper {
    my ($self) = @_;
    my @candidates;
    push @candidates, File::Spec->catfile($self->{local_macro_dir}, 'importallmacros_ue.sas')
      if defined $self->{local_macro_dir} && length $self->{local_macro_dir};

    my $module_file = abs_path(__FILE__) || File::Spec->rel2abs(__FILE__);
    $module_file =~ s{\\}{/}g;
    my $module_dir = dirname($module_file);
    push @candidates, File::Spec->catfile($module_dir, 'importallmacros_ue.sas');

    my %seen;
    for my $path (@candidates) {
        next unless defined $path && length $path;
        next if $seen{$path}++;
        return $path if -e $path;
    }
    return;
}

sub _ensure_remote_macro_bootstrap_helper {
    my ($self) = @_;
    my $local_helper = $self->_find_local_macro_bootstrap_helper();
    return '' unless $local_helper;

    warn "Checking SAS ODA macro bootstrap helper upload/reuse: $local_helper\n";
    my $remote = eval {
        $self->upload(
            $local_helper,
            {
                progress_label => 'macro bootstrap helper: ' . basename($local_helper),
                skip_if_same   => 1,
                timeout_seconds => $MACRO_HELPER_UPLOAD_TIMEOUT_SECONDS,
            }
        );
    };
    if ($remote && $remote !~ /^PYTHON ERROR/) {
        return "Checked/reused/uploaded macro bootstrap helper: $remote";
    }

    my $detail = $@ || $remote || 'unknown upload failure';
    die "Could not verify/upload macro bootstrap helper $local_helper before loading ~/Macros: $detail\n";
}

sub _process_dependencies {
    my ($self, $code) = @_;
    my @logs;
    my %uploaded;
    my $scan_code = _dependency_scan_code($code);
    my %defined_in_code = map { lc($_) => 1 } ($scan_code =~ /%macro\s+([A-Za-z_]\w*)\b/ig);

    while ($scan_code =~ /%include\s+["'](.+?)["']/gi) {
        my $path = $1;
        if (-e $path && !$uploaded{$path}++) {
            _warn_dependency_upload(kind => '%include target', path => $path);
            my $remote = eval {
                $self->upload(
                    $path,
                    {
                        progress_label => '%include target: ' . basename($path),
                    }
                );
            };
            if ($remote && $remote !~ /^PYTHON ERROR/) {
                push @logs, "Uploaded %include: $remote";
                $code =~ s/\Q$path\E/$remote/g;
            }
        }
    }

    my @potential_macros = ($scan_code =~ /%(\w+)/g);
    my $header_includes = "";
    my @unresolved_macro_names;
    foreach my $m_name (@potential_macros) {
        next if _is_builtin_macro_name($m_name);
        next if $defined_in_code{lc $m_name};
        my $local_m_path = $self->_find_local_macro_file($m_name);
        if (defined $local_m_path && -e $local_m_path && !$uploaded{$local_m_path}++) {
            my ($should_overlay, $overlay_reason) = _autoload_macros_enabled()
              ? $self->_local_macro_should_overlay_remote($m_name, $local_m_path)
              : (1, 'global macro autoload disabled; targeted local macro overlay required');
            if ($should_overlay) {
                _warn_dependency_upload(kind => 'macro file', detail => "%$m_name", path => $local_m_path);
                my $remote = eval {
                    $self->upload(
                        $local_m_path,
                        {
                            progress_label => "macro file for %$m_name: " . basename($local_m_path),
                        }
                    );
                };
                if ($remote && $remote !~ /^PYTHON ERROR/) {
                    push @logs, "Detected local macro: %$m_name. Uploaded overlay to $remote ($overlay_reason)";
                    $header_includes .= qq{%include "$remote";\n};
                } else {
                    push @logs, "Could not upload local macro overlay for %$m_name; falling back to remote/global macro resolution.";
                    push @unresolved_macro_names, $m_name;
                }
            } else {
                push @logs, "Detected local macro: %$m_name. Keeping ODA ~/Macros copy because $overlay_reason.";
                push @unresolved_macro_names, $m_name unless _autoload_macros_enabled();
            }
        } else {
            push @unresolved_macro_names, $m_name;
        }
    }

    my $targeted_remote_loader = _autoload_macros_enabled()
      ? ''
      : $self->_build_targeted_remote_macro_loader(\@unresolved_macro_names);
    if (length $targeted_remote_loader) {
        $header_includes = $targeted_remote_loader . "\n" . $header_includes;
        my @expanded_targeted_names = _expanded_targeted_remote_macro_names(\@unresolved_macro_names);
        push @logs, "Injected targeted remote macro loader for: " . join(', ', @expanded_targeted_names);
    } elsif (@unresolved_macro_names && _autoload_macros_enabled()) {
        push @logs, "Using global importallmacros_ue bootstrap for unresolved remote macros: " . join(', ', @unresolved_macro_names);
    }

    my $upload_dependency = sub {
        my ($cmd, $path) = @_;
        next if $path =~ /^\/home\// || $path =~ /&/;
        my $local_path = $self->_resolve_local_dependency_path($path);
        return unless $local_path && !$uploaded{$local_path}++;
        my $detail = $cmd;
        $detail =~ s/\s+$//;
        _warn_dependency_upload(kind => 'file dependency', detail => $detail, path => $path);
        my $remote = eval {
            $self->upload(
                $local_path,
                {
                    progress_label => "file dependency ($detail): " . basename($local_path),
                }
            );
        };
        if ($remote && $remote !~ /^PYTHON ERROR/) {
            push @logs, "Detected $cmd dependency. Uploaded: $path -> $remote";
            $code =~ s/\Q$path\E/$remote/g;
        }
    };

    my $sas_path_regex = qr/(?i)\b(datafile\s*=\s*|outfile\s*=\s*|zip\s*=\s*|infile\s+|file\s+|filename\s+\S+\s+|libname\s+\S+\s+)(["'])([^"']+)\2/;
    while ($scan_code =~ /$sas_path_regex/g) {
        my ($cmd, $quote, $path) = ($1, $2, $3);
        $upload_dependency->($cmd, $path);
    }

    my $sas_unquoted_assignment_regex = qr/(?i)\b(datafile\s*=\s*|outfile\s*=\s*|zip\s*=\s*)([^\s,;\)\r\n]+)/;
    while ($scan_code =~ /$sas_unquoted_assignment_regex/g) {
        my ($cmd, $path) = ($1, $2);
        next unless defined $path && length $path;
        next if $path =~ /^["']/;
        $upload_dependency->($cmd, $path);
    }

    return ($header_includes . $code, join("\n", @logs));
}

sub run_code {
    my ($self, $sas_code) = @_;
    my ($processed_code, $dep_logs) = $self->_process_dependencies($sas_code);
    my $has_local_macro_upload = ($dep_logs // '') =~ /Uploaded overlay to/ ? 1 : 0;
    my $has_targeted_remote_loader = ($dep_logs // '') =~ /Injected targeted remote macro loader/ ? 1 : 0;
    my $macro_autoload_enabled = _autoload_macros_enabled() ? 1 : 0;
    my $disable_global_macro_bootstrap = $macro_autoload_enabled ? 0 : 1;
    $self->_start_server_if_needed() if $self->{persistent} && $self->{session_id};
    if ($macro_autoload_enabled && !$disable_global_macro_bootstrap) {
        if ($has_targeted_remote_loader || $has_local_macro_upload) {
            warn "Loading all SAS macros from ~/Macros via importallmacros_ue; this can take a few minutes on a fresh SAS ODA session. Reuse --persistent --session-id <id> to avoid repeating this bootstrap.\n";
        }
        my $macro_bootstrap_dep_log = $self->_ensure_remote_macro_bootstrap_helper();
        if (defined $macro_bootstrap_dep_log && length $macro_bootstrap_dep_log) {
            $dep_logs = length($dep_logs)
              ? join("\n", $dep_logs, $macro_bootstrap_dep_log)
              : $macro_bootstrap_dep_log;
        }
        if ($has_targeted_remote_loader) {
            my $msg = 'Keeping global importallmacros_ue bootstrap enabled for SAS submit; targeted remote macro loading is supplemental only.';
            $dep_logs = length($dep_logs) ? join("\n", $dep_logs, $msg) : $msg;
        } elsif ($has_local_macro_upload) {
            my $msg = 'Keeping global importallmacros_ue bootstrap enabled before uploaded local macro %include blocks, so ~/Macros are loaded first.';
            $dep_logs = length($dep_logs) ? join("\n", $dep_logs, $msg) : $msg;
        }
    } else {
        my $disable_msg = 'Global importallmacros_ue bootstrap disabled via SAS_ODA_AUTOLOAD_MACROS=0 for this submit.';
        $dep_logs = length($dep_logs)
          ? join("\n", $dep_logs, $disable_msg)
          : $disable_msg;
    }

    my $result;
    my $macro_bootstrap_meta;
    local $ENV{SAS_ODA_AUTOLOAD_MACROS} = 0 if $disable_global_macro_bootstrap;
    if ($self->{requested_persistent} && $self->{session_id}) {
        my $load_macros = (_autoload_macros_enabled() && !$disable_global_macro_bootstrap) ? 1 : 0;
        my $submit_timeout = _effective_persistent_submit_timeout_seconds(
            load_macros => $load_macros,
        );
        $self->_start_server_if_needed();
        my $resp = _call_session_server(
            {
                cmd         => 'submit',
                session_id  => $self->{session_id},
                code        => $processed_code,
                load_macros => $load_macros,
            },
            $submit_timeout,
        );
        my $resp_log = '';
        my $resp_lst = '';
        if (ref $resp eq 'HASH') {
            $resp_log = $resp->{log} // $resp->{server_log_tail} // '';
            $resp_lst = $resp->{lst} // '';
            $macro_bootstrap_meta = $resp->{macro_bootstrap_meta} if ref($resp->{macro_bootstrap_meta}) eq 'HASH';
        }
        if (!$resp || ($resp->{status} && $resp->{status} ne 'ok')) {
            if (_session_server_error_is_transport($resp)) {
                warn "Warning: persistent-session SAS submit hit a transport/timeout failure; restarting the local SAS ODA session server so the next run starts cleanly.\n";
                $self->_restart_session_server();
            }
            return { error => $resp->{error} // 'session server error', log => $resp_log, lst => $resp_lst, dep_logs => $dep_logs };
        }
        $result = [ $resp_log, $resp_lst, undef ];
    } else {
        my $resp = eval { _run_nonpersistent_sas_logic_via_python($processed_code) };
        if ($@) {
            return { error => $@, log => '', lst => '', dep_logs => $dep_logs };
        }
        if (!$resp || ($resp->{status} // '') ne 'ok') {
            return {
                error => $resp->{error} // 'inline SAS Python helper error',
                log => $resp->{log} // '',
                lst => $resp->{lst} // '',
                dep_logs => $dep_logs,
            };
        }
        $macro_bootstrap_meta = $resp->{macro_bootstrap_meta} if ref($resp->{macro_bootstrap_meta}) eq 'HASH';
        $result = [ $resp->{log} // '', $resp->{lst} // '', undef ];
    }

    if ($@ || !$result || $result->[0] eq "ERROR") {
        return { error => $@ // ($result ? $result->[1] : 'unknown error'), log => "", lst => "", dep_logs => $dep_logs };
    }

    my $output = "";
    my $htmlfilename="";
    if ($self->{open_html} && $result->[1] && length($result->[1]) > 100) {
        my $fh;
        ($fh, $htmlfilename) = tempfile(TEMPLATE => 'sas_res_XXXXX', SUFFIX => '.html', UNLINK => 0);
        print $fh $result->[1];
        close $fh;
#        system("cygstart", $htmlfilename);
        $output = "HTML output saved to: $htmlfilename\n";
    }

    if (ref($macro_bootstrap_meta) eq 'HASH' && keys %{$macro_bootstrap_meta}) {
        my @notes;
        push @notes, "Bootstrap Start: " . $macro_bootstrap_meta->{started_at}
          if defined($macro_bootstrap_meta->{started_at}) && length($macro_bootstrap_meta->{started_at});
        push @notes, "Bootstrap End: " . $macro_bootstrap_meta->{finished_at}
          if defined($macro_bootstrap_meta->{finished_at}) && length($macro_bootstrap_meta->{finished_at});
        push @notes, "Bootstrap Elapsed Seconds: " . $macro_bootstrap_meta->{elapsed_seconds}
          if defined($macro_bootstrap_meta->{elapsed_seconds}) && $macro_bootstrap_meta->{elapsed_seconds} ne '';
        push @notes, "Bootstrap OK: " . ($macro_bootstrap_meta->{ok} // '')
          if defined($macro_bootstrap_meta->{ok}) && length($macro_bootstrap_meta->{ok});
        push @notes, "Bootstrap Warning: " . (($macro_bootstrap_meta->{warning}) ? 1 : 0)
          if exists $macro_bootstrap_meta->{warning};
        push @notes, "Bootstrap-only SAS log: " . $macro_bootstrap_meta->{log_path}
          if defined($macro_bootstrap_meta->{log_path}) && length($macro_bootstrap_meta->{log_path});
        if (@notes) {
            my $bootstrap_note = "=== Macro Bootstrap Diagnostics ===\n" . join("\n", @notes);
            $dep_logs = length($dep_logs) ? join("\n\n", $dep_logs, $bootstrap_note) : $bootstrap_note;
        }
    }

    return {
        log => $result->[0],
        lst => $result->[1],
        dep_logs => $dep_logs,
        output => $output,
        htmlfilename=> $htmlfilename,
        macro_bootstrap_meta => $macro_bootstrap_meta,
    };
}

sub run_file {
    my ($self, $sas_file) = @_;
    open my $fh, '<', $sas_file or die "Could not open file: $!";
    my $sas_code = do { local $/; <$fh> };
    close $fh;
    return $self->run_code($sas_code);
}

sub filesindir {
    my ($self, $remote_path) = @_;
    if ($self->{persistent} && $self->{session_id}) {
        my $resp = $self->_call_persistent_session_server(
            { cmd => 'dirlist', session_id => $self->{session_id}, remote_path => $remote_path },
            $SERVER_METADATA_TIMEOUT_SECONDS,
            'remote dir listing',
        );
        return $resp->{files} if $resp && ($resp->{status} // '') eq 'ok';
        return "PYTHON ERROR: " . ($resp->{error} // 'session server error');
    }
    my ($result, $sess) = eval { dirlist($remote_path, $self->{_session}) };
    $self->{_session} = $sess;
    return $result;
}

sub fileinfo {
    my ($self, $remote_path) = @_;
    if ($self->{persistent} && $self->{session_id}) {
        my $resp = $self->_call_persistent_session_server(
            { cmd => 'fileinfo', session_id => $self->{session_id}, remote_path => $remote_path },
            $SERVER_METADATA_TIMEOUT_SECONDS,
            'remote file-info lookup',
        );
        return $resp->{info} if $resp && ($resp->{status} // '') eq 'ok';
        return "PYTHON ERROR: " . ($resp->{error} // 'session server error');
    }
    my ($result, $sess) = eval { remote_file_info($remote_path, $self->{_session}) };
    $self->{_session} = $sess;
    return $result;
}

sub upload {
    my ($self, $local_path, $opts) = @_;
    $opts = {} unless ref($opts) eq 'HASH';
    my $progress_label = $opts->{progress_label} // '';
    my $skip_if_same = exists $opts->{skip_if_same} ? ($opts->{skip_if_same} ? 1 : 0) : 1;
    my $timeout_seconds = _effective_upload_timeout_seconds(
        local_path      => $local_path,
        timeout_seconds => $opts->{timeout_seconds},
    );
    if ($self->_should_use_direct_upload_for_persistent_session(local_path => $local_path)) {
        my $threshold_bytes = _persistent_direct_upload_threshold_bytes();
        warn "Using direct SAS ODA upload path for large persistent transfer ($local_path, threshold=${threshold_bytes} bytes) to avoid long-lived session-server socket stalls.\n";
        my ($result, $sess) = eval { upload_file($local_path, $self->{_transfer_session}, $progress_label, $skip_if_same) };
        $self->{_transfer_session} = $sess if ref $sess;
        return $result if defined $result && $result !~ /^PYTHON ERROR/;
        my $detail = $@ || $result || 'direct upload failure';
        return "PYTHON ERROR: $detail";
    }
    if ($self->{persistent} && $self->{session_id}) {
        my $resp = $self->_call_persistent_session_server(
            {
                cmd            => 'upload',
                session_id     => $self->{session_id},
                local_path     => $local_path,
                progress_label => $progress_label,
                skip_if_same   => $skip_if_same,
            },
            $timeout_seconds,
            'remote upload',
        );
        return $resp->{remote_path} if $resp && ($resp->{status} // '') eq 'ok';
        return "PYTHON ERROR: " . ($resp->{error} // 'session server error');
    }
    my ($result, $sess) = eval { upload_file($local_path, $self->{_session}, $progress_label, $skip_if_same) };
    $self->{_session} = $sess;
    return $result;
}

sub download {
    my ($self, $remote_path, $local_path) = @_;
    if ($self->{persistent} && $self->{session_id}) {
        my $resp = $self->_call_persistent_session_server(
            { cmd => 'download', session_id => $self->{session_id}, remote_path => $remote_path, local_path => $local_path },
            $SERVER_DOWNLOAD_TIMEOUT_SECONDS,
            'remote download',
        );
        return $resp->{local_path} if $resp && ($resp->{status} // '') eq 'ok';
        return "PYTHON ERROR: " . ($resp->{error} // 'session server error');
    }
    my ($result, $sess) = eval { download_file($remote_path, $local_path, $self->{_session}) };
    $self->{_session} = $sess;
    return $result;
}

sub delete {
    my ($self, $remote_file, $remote_dir) = @_;
    if ($self->{persistent} && $self->{session_id}) {
        my $resp = $self->_call_persistent_session_server(
            { cmd => 'delete', session_id => $self->{session_id}, remote_file => $remote_file, remote_dir => $remote_dir },
            $SERVER_DELETE_TIMEOUT_SECONDS,
            'remote delete',
        );
        return $resp->{msg} if $resp && ($resp->{status} // '') eq 'ok';
        return "PYTHON ERROR: " . ($resp->{error} // 'session server error');
    }
    my ($result, $sess) = eval { delete_file($remote_file, $remote_dir, $self->{_session}) };
    $self->{_session} = $sess;
    return $result;
}

sub get_sas_home_path {
    my ($self) = @_;
    if ($self->{persistent} && $self->{session_id}) {
        my $resp = $self->_call_persistent_session_server(
            { cmd => 'gethome', session_id => $self->{session_id} },
            $SERVER_GETHOME_TIMEOUT_SECONDS,
            'remote home lookup',
        );
        return $resp->{home} if $resp && ($resp->{status} // '') eq 'ok';
        return "PYTHON ERROR: " . ($resp->{error} // 'session server error');
    }
    my ($result, $sess) = eval { get_sas_home($self->{_session}) };
    $self->{_session} = $sess;
    return $result;
}   

=head1 DESCRIPTION

SAS_ODA_Runner provides a Perl interface to run SAS code on remote ODA systems using saspy. 
It handles automatic dependency resolution, file uploads/downloads, and macro management.

=head1 METHODS

=head2 new(%args)

Creates a new SAS_ODA_Runner instance.

    my $runner = SAS_ODA_Runner->new(
        local_macro_dir => './macros',  # Directory containing SAS macros (optional, default: './')
        open_html => 1,                 # Auto-open HTML output in browser (optional, default: 1)
    );

=head2 run_code($sas_code)

Executes SAS code and returns results.

    my $result = $runner->run_code('proc print data=sashelp.class; run;');
    
    # Returns hashref with keys:
    # - log: SAS log output
    # - lst: SAS listing/HTML output
    # - dep_logs: Dependency processing logs
    # - output: Path to HTML file if generated
    # - error: Error message if execution failed

=head2 run_file($sas_file)

Reads and executes a SAS file.

    my $result = $runner->run_file('/path/to/script.sas');

=head2 upload($local_path)

Uploads a local file to the remote SAS system.

    my $remote_path = $runner->upload('/local/file.txt');

=head2 download($remote_path, $local_path)

Downloads a file from the remote SAS system.

    $runner->download('/remote/file.txt', '/local/path/');

=head2 get_sas_home_path()

Gets the SAS home directory path on the remote system.

    my $sas_home = $runner->get_sas_home_path();

=head1 FEATURES

- Automatic %include file uploads
- Macro detection and dependency resolution
- Data file and INFILE/OUTFILE path handling
- Session persistence across multiple calls
- HTML output generation

=head1 EXAMPLE

    use SAS_ODA_Runner;
    
    my $runner = SAS_ODA_Runner->new(local_macro_dir => './my_macros');
    
    my $result = $runner->run_code(q{
        %my_macro(param1=value1);
        proc means data=sashelp.class;
        run;
    });
    
    die $result->{error} if $result->{error};
    print "Log:\n", $result->{log};

=head1 AUTHOR

Your Organization

=cut

1;
