"""Archive transfer helpers shared with the established SAS ZIP protocol.
All operations use the supplied live session; no secondary SAS login is created.
"""
import os, uuid, zipfile, tempfile, shutil, re

class ArchiveSession:
    def __init__(self, sas, home, fileinfo):
        self.sas=sas; self.home=home; self.fallback_fileinfo=fileinfo; self.cache={}
    def fileinfo(self,path):
        return self.cache[path] if path in self.cache else self.fallback_fileinfo(path)
    def prime_fileinfo(self,paths):
        token='MCPMETA_'+uuid.uuid4().hex
        code=[]
        for i,path in enumerate(paths):
            physical=self.home.rstrip('/')+'/'+path[2:] if path.startswith('~/') else path
            q=physical.replace('"','""')
            code += [f'filename mbmeta "{q}";', 'data _null_;',
                "e=fexist('mbmeta'); n=.; f=fopen('mbmeta','I',1,'B');",
                "if f>0 then do; n=input(compress(finfo(f,'File Size (bytes)')),best32.); if missing(n) then n=input(compress(finfo(f,'File Size')),best32.);r=fclose(f);end;",
                f'put "{token}|{i}|" e 1. "|" n best32.;', 'run;', 'filename mbmeta clear;']
        log=self.sas.submit('\n'.join(code)).get('LOG','')
        found={}
        for line in log.splitlines():
            if line.startswith(token+'|'):
                _,idx,exists,size=line.split('|');found[int(idx)]={'exists':exists.strip()=='1','size':int(size.strip()) if size.strip()!='.' else None,'path':paths[int(idx)]}
        if len(found)!=len(paths):raise IOError('Incomplete batch file metadata')
        self.cache.update({paths[i]:info for i,info in found.items()})
    def submit(self, code): return self.sas.submit(code)
    def symget(self, name): return self.sas.symget(name)

def get_session(s): return s,s
def get_sas_home(s): return s.home,s
def run_fileinfo(s,p): return s.fileinfo(p)
def remote_file_info(p,s): return run_fileinfo(s,p),s
def upload_file(p,s,label=None,skip_if_same=False):
    remote=s.home.rstrip('/')+'/'+os.path.basename(p)
    result=s.sas.upload(p,remote,overwrite=True)
    if not result.get('Success'): raise IOError('SASPy upload failed')
    if not _remote_upload_size_ok(run_fileinfo(s,remote),os.path.getsize(p)):
        raise IOError('Uploaded archive size mismatch')
    return remote,s
def download_file(remote,local,s):
    result=s.sas.download(local,remote,overwrite=True)
    if not result.get('Success'): raise IOError('SASPy download failed')
    return local,s

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
    created_remote = remote_info.get('created_epoch')
    created_local = local_meta.get('created_epoch')
    if created_remote is not None and created_local is not None:
        try:
            return abs(int(created_remote) - int(created_local)) <= 2
        except Exception:
            pass

    modified_remote = remote_info.get('modified_epoch')
    modified_local = local_meta.get('modified_epoch')
    if modified_remote is not None and modified_local is not None:
        try:
            return abs(int(modified_remote) - int(modified_local)) <= 2
        except Exception:
            pass

    return False

def _remote_upload_size_ok(remote_info, expected_size):
    if not isinstance(remote_info, dict) or not remote_info.get('exists'):
        return False
    remote_size = remote_info.get('size')
    if remote_size is None:
        return False
    try:
        return int(remote_size) == int(expected_size or 0)
    except Exception:
        return False

def _sas_archive_quote(value):
    return str(value or '').replace('"', '""')

def _archive_transfer_enabled(payload):
    value = payload.get('archive_transfers', True)
    if isinstance(value, str):
        return value.strip().lower() not in ('0', 'false', 'no', 'off')
    return bool(value)

def _archive_member_name(index, token):
    return f"mgw_{token}_{index + 1:06d}.bin"

def _submit_archive_code(session, sas_code, operation):
    res = session.submit(sas_code)
    log = str((res or {}).get('LOG', ''))
    try:
        failed = str(session.symget('_mg_archive_error') or '').strip()
    except Exception:
        failed = ''
    log_has_error = any(line.lstrip().startswith('ERROR:') for line in log.splitlines())
    if failed not in ('', '0', '0.0') or log_has_error:
        raise IOError(f"SAS ODA {operation} reported a file-copy failure.\n{log}")
    return res

def _cleanup_remote_archive_paths(session, paths):
    paths = [str(path or '') for path in paths if str(path or '')]
    if not paths:
        return
    statements = []
    for index, path in enumerate(paths):
        fileref = f"c{index + 1:07d}"[-8:]
        statements.extend([
            f'filename {fileref} "{_sas_archive_quote(path)}";',
            'data _null_;',
            f"  if fexist('{fileref}') then rc=fdelete('{fileref}');",
            'run;',
            f'filename {fileref} clear;',
        ])
    try:
        session.submit('\n'.join(statements))
    except Exception:
        pass

def upload_files_archive(items, session_obj):
    """Upload one local ZIP, extract its generated members in SAS HOME, and verify sizes."""
    session, session_obj = get_session(session_obj)
    home, session_obj = get_sas_home(session_obj)
    home = str(home or '').rstrip('/')
    token = uuid.uuid4().hex[:12]
    archive_name = f"multigwas_upload_{token}.zip"
    local_archive = os.path.join(tempfile.gettempdir(), archive_name)
    remote_archive = f"{home}/{archive_name}"
    remote_archive_uploaded = False
    prepared = []
    reused_results = []
    remote_names = set()
    try:
        with zipfile.ZipFile(local_archive, 'w', compression=zipfile.ZIP_DEFLATED, allowZip64=True) as bundle:
            for index, item in enumerate(items):
                local_path = os.path.abspath(str(item.get('local_path', '') or ''))
                if not os.path.isfile(local_path):
                    raise FileNotFoundError(f"Upload source does not exist: {local_path}")
                remote_name = os.path.basename(local_path.replace('\\', '/'))
                if not remote_name:
                    raise ValueError(f"Could not determine remote basename for upload: {local_path}")
                if remote_name in remote_names:
                    raise ValueError(f"Archive upload has duplicate remote basename: {remote_name}")
                remote_names.add(remote_name)
                member = _archive_member_name(index, token)
                remote_path = f"{home}/{remote_name}"
                if bool(item.get('skip_if_same', True)):
                    try:
                        existing_info = run_fileinfo(session, remote_path)
                    except Exception:
                        existing_info = None
                    if _remote_file_matches_local_upload(existing_info, local_path):
                        print(
                            f"Archive upload manifest: {remote_name} already matches local size/timestamp; reusing it.",
                            flush=True,
                        )
                        reused_results.append({
                            'local_path': item.get('local_path', ''),
                            'remote_path': remote_path,
                            'archive_transfer': False,
                            'reused': True,
                        })
                        continue
                bundle.write(local_path, member)
                prepared.append({
                    'item': item,
                    'local_path': local_path,
                    'remote_name': remote_name,
                    'remote_path': remote_path,
                    'member': member,
                    'size': os.path.getsize(local_path),
                })
        if not prepared:
            return reused_results, session_obj
        if len(prepared) == 1 and "'" not in prepared[0]['remote_name']:
            entry = prepared[0]
            uploaded_path, session_obj = upload_file(
                entry['local_path'],
                session_obj,
                entry['item'].get('progress_label'),
                False,
            )
            if not uploaded_path or str(uploaded_path).startswith('PYTHON ERROR:'):
                raise IOError(str(uploaded_path or 'single pending upload returned no remote path'))
            reused_results.append({
                'local_path': entry['item'].get('local_path', ''),
                'remote_path': uploaded_path,
                'archive_transfer': False,
            })
            return reused_results, session_obj
        print(
            f"Archive upload: bundling {len(prepared)} files into one SASPy transfer "
            f"({os.path.getsize(local_archive):,} bytes).",
            flush=True,
        )
        uploaded_path, session_obj = upload_file(
            local_archive,
            session_obj,
            f"archive containing {len(prepared)} files",
            False,
        )
        if not uploaded_path or str(uploaded_path).startswith('PYTHON ERROR:'):
            raise IOError(str(uploaded_path or 'archive upload returned no remote path'))
        remote_archive = str(uploaded_path)
        remote_archive_uploaded = True
        statements = ['%let _mg_archive_error=0;']
        for index, entry in enumerate(prepared):
            zin = f"zi{index + 1:06d}"[-8:]
            zout = f"zo{index + 1:06d}"[-8:]
            statements.extend([
                f'filename {zout} "{_sas_archive_quote(entry["remote_path"])}" recfm=n;',
                'data _null_;',
                f"  if fexist('{zout}') then do;",
                f"    rc_delete=fdelete('{zout}');",
                '    if rc_delete ne 0 then do;',
                "      call symputx('_mg_archive_error','1','G');",
                f'      put "ERROR: Could not replace existing archive destination {entry["remote_name"]}: " rc_delete=;',
                '    end;',
                '  end;',
                'run;',
                f'filename {zout} clear;',
                f'filename {zin} ZIP "{_sas_archive_quote(remote_archive)}" member="{entry["member"]}";',
                f'filename {zout} "{_sas_archive_quote(entry["remote_path"])}" recfm=n;',
                'data _null_;',
                f'  infile {zin} lrecl=32767 recfm=f length=_mg_len eof=_mg_eof unbuf;',
                f'  file {zout} lrecl=32767 recfm=n;',
                '  input;',
                '  put _infile_ $varying32767. _mg_len;',
                '  return;',
                '  _mg_eof: stop;',
                'run;',
                f'filename {zin} clear;',
                f'filename {zout} clear;',
            ])
        _submit_archive_code(session, '\n'.join(statements), 'archive extraction')
        session.prime_fileinfo([entry["remote_path"] for entry in prepared])
        results = list(reused_results)
        for entry in prepared:
            info = run_fileinfo(session, entry['remote_path'])
            if not _remote_upload_size_ok(info, entry['size']):
                got = info.get('size') if isinstance(info, dict) else None
                raise IOError(
                    f"Extracted remote file size mismatch for {entry['remote_path']}: "
                    f"expected {entry['size']} bytes, got {got}"
                )
            results.append({
                'local_path': entry['item'].get('local_path', ''),
                'remote_path': entry['remote_path'],
                'archive_transfer': True,
            })
        print(f"Archive upload verified {len(results)} extracted SAS ODA files.", flush=True)
        return results, session_obj
    finally:
        if remote_archive_uploaded:
            _cleanup_remote_archive_paths(session, [remote_archive])
        try:
            if os.path.exists(local_archive):
                os.unlink(local_archive)
        except Exception:
            pass

def download_files_archive(items, session_obj):
    """Create one ZIP in SAS HOME, download it once, safely extract locally, and verify sizes."""
    session, session_obj = get_session(session_obj)
    home, session_obj = get_sas_home(session_obj)
    home = str(home or '').rstrip('/')
    token = uuid.uuid4().hex[:12]
    archive_name = f"multigwas_download_{token}.zip"
    remote_archive = f"{home}/{archive_name}"
    local_archive = os.path.join(tempfile.gettempdir(), archive_name)
    prepared = []
    local_parts = []
    staging_remote_paths = []
    local_destinations = set()
    try:
        for index, item in enumerate(items):
            requested_remote = str(item.get('remote_path', '') or '')
            info, session_obj = remote_file_info(requested_remote, session_obj)
            if not isinstance(info, dict) or not info.get('exists'):
                raise FileNotFoundError(f"Remote file does not exist in SAS ODA: {requested_remote}")
            local_path = str(item.get('local_path', '') or '')
            if not local_path.strip():
                local_path = os.path.basename(requested_remote)
            local_path = os.path.abspath(local_path)
            normalized_destination = os.path.normcase(local_path)
            if normalized_destination in local_destinations:
                raise ValueError(f"Archive download has duplicate local destination: {local_path}")
            local_destinations.add(normalized_destination)
            member = _archive_member_name(index, token)
            stage_path = f"{home}/{member}"
            staging_remote_paths.append(stage_path)
            prepared.append({
                'item': item,
                'remote_path': info.get('path') or requested_remote,
                'local_path': local_path,
                'member': member,
                'stage_path': stage_path,
                'size': int(info.get('size') or 0),
            })

        statements = ['%let _mg_archive_error=0;']
        statements.extend([
            f'filename mgzout "{_sas_archive_quote(remote_archive)}";',
            'data _null_;',
            "  if fexist('mgzout') then rc=fdelete('mgzout');",
            'run;',
            'filename mgzout clear;',
        ])
        for index, entry in enumerate(prepared):
            src = f"ds{index + 1:06d}"[-8:]
            dst = f"dt{index + 1:06d}"[-8:]
            statements.extend([
                f'filename {src} "{_sas_archive_quote(entry["remote_path"])}" recfm=n;',
                f'filename {dst} "{_sas_archive_quote(entry["stage_path"])}" recfm=n;',
                'data _null_;',
                f"  if fexist('{dst}') then rc_delete=fdelete('{dst}');",
                f"  rc=fcopy('{src}','{dst}');",
                '  if rc ne 0 then do;',
                "    call symputx('_mg_archive_error','1','G');",
                f'    put "ERROR: Could not stage remote archive member {entry["member"]}: " rc=;',
                '  end;',
                'run;',
                f'filename {src} clear;',
                f'filename {dst} clear;',
            ])
        statements.append('ods package(mgwpkg) open nopf;')
        for entry in prepared:
            statements.append(f'ods package(mgwpkg) add file="{_sas_archive_quote(entry["stage_path"])}";')
        statements.extend([
            'ods package(mgwpkg) publish archive',
            '  properties(',
            f'    archive_name="{_sas_archive_quote(archive_name)}"',
            f'    archive_path="{_sas_archive_quote(home)}"',
            '  );',
            'ods package(mgwpkg) close;',
            f'filename mgmeta ZIP "{_sas_archive_quote(remote_archive)}" member="PackageMetaData";',
            'data _null_;',
            "  if fexist('mgmeta') then rc=fdelete('mgmeta');",
            'run;',
            'filename mgmeta clear;',
        ])
        for index, entry in enumerate(prepared):
            stage = f"dx{index + 1:06d}"[-8:]
            statements.extend([
                f'filename {stage} "{_sas_archive_quote(entry["stage_path"])}";',
                'data _null_;',
                f"  if fexist('{stage}') then rc=fdelete('{stage}');",
                'run;',
                f'filename {stage} clear;',
            ])
        _submit_archive_code(session, '\n'.join(statements), 'archive creation')
        archive_info = run_fileinfo(session, remote_archive)
        if not isinstance(archive_info, dict) or not archive_info.get('exists') or int(archive_info.get('size') or 0) <= 0:
            raise IOError(f"SAS ODA did not create a non-empty download archive: {remote_archive}")
        print(
            f"Archive download: transferring {len(prepared)} files in one SASPy download "
            f"({int(archive_info.get('size') or 0):,} bytes).",
            flush=True,
        )
        downloaded, session_obj = download_file(remote_archive, local_archive, session_obj)
        if not downloaded:
            raise IOError(f"Archive download returned no local path for {remote_archive}")
        with zipfile.ZipFile(local_archive, 'r') as bundle:
            names = set(bundle.namelist())
            missing = [entry['member'] for entry in prepared if entry['member'] not in names]
            if missing:
                raise IOError(f"Downloaded archive is missing expected members: {', '.join(missing)}")
            for entry in prepared:
                local_dir = os.path.dirname(entry['local_path'])
                if local_dir:
                    os.makedirs(local_dir, exist_ok=True)
                fd, part_path = tempfile.mkstemp(prefix='.sas_oda_archive_', dir=(local_dir or '.'))
                os.close(fd)
                local_parts.append((part_path, entry['local_path']))
                with bundle.open(entry['member'], 'r') as source, open(part_path, 'wb') as target:
                    shutil.copyfileobj(source, target, length=1024 * 1024)
                actual_size = os.path.getsize(part_path)
                if actual_size != entry['size']:
                    raise IOError(
                        f"Downloaded archive member size mismatch for {entry['remote_path']}: "
                        f"expected {entry['size']} bytes, got {actual_size}"
                    )
        for part_path, final_path in local_parts:
            os.replace(part_path, final_path)
        local_parts = []
        results = [{
            'remote_path': entry['item'].get('remote_path', ''),
            'local_path': entry['local_path'],
            'archive_transfer': True,
        } for entry in prepared]
        print(f"Archive download verified and extracted {len(results)} local files.", flush=True)
        return results, session_obj
    finally:
        _cleanup_remote_archive_paths(session, [remote_archive] + staging_remote_paths)
        for part_path, _ in local_parts:
            try:
                if os.path.exists(part_path):
                    os.unlink(part_path)
            except Exception:
                pass
        try:
            if os.path.exists(local_archive):
                os.unlink(local_archive)
        except Exception:
            pass

def transfer_many(sas,payload,home,fileinfo):
    adapter=ArchiveSession(sas,home,fileinfo)
    uploads=payload.get('uploads',[]); downloads=payload.get('downloads',[])
    if _archive_transfer_enabled(payload) and len(uploads)>=2:
        up,_=upload_files_archive(uploads,adapter)
    else:
        up=[]
        for item in uploads:
            p=os.path.abspath(item['local_path']);remote=home.rstrip('/')+'/'+os.path.basename(p)
            if item.get('skip_if_same',True) and _remote_file_matches_local_upload(fileinfo(remote),p):
                up.append(dict(item,remote_path=remote,reused=True,archive_transfer=False));continue
            remote,_=upload_file(p,adapter)
            up.append(dict(item,remote_path=remote,archive_transfer=False))
    if _archive_transfer_enabled(payload) and len(downloads)>=2:
        adapter.prime_fileinfo([item['remote_path'] for item in downloads])
        down,_=download_files_archive(downloads,adapter)
    else:
        down=[]
        for item in downloads:
            info=fileinfo(item['remote_path'])
            if not info.get('exists'): raise FileNotFoundError(item['remote_path'])
            local=os.path.abspath(item.get('local_path') or os.path.basename(item['remote_path']))
            os.makedirs(os.path.dirname(local),exist_ok=True)
            download_file(info.get('path') or item['remote_path'],local,adapter)
            if os.path.getsize(local)!=int(info['size']): raise IOError('Downloaded file size mismatch')
            down.append(dict(item,local_path=local,archive_transfer=False))
    return {'uploads':up,'downloads':down}
