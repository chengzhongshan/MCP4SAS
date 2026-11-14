"""Maintainer-only baseline inventory and unchanged Python/SAS asset extraction.

This build-time utility reads Git objects. Installed runtime never calls Git or Perl.
"""
import csv
import hashlib
import json
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[1]
BASELINE = '796c37b39e5c3017493de227b244413f8e684141'
OUT = Path(__file__).resolve().parent

def original(name):
    return subprocess.check_output(['git','show',f'{BASELINE}:{name}'],cwd=ROOT)

def main():
    vendor = OUT/'backend'
    vendor.mkdir(exist_ok=True)
    sources = {}
    for source,target in [('MCPDeps/sas_oda_session_server.py','session_backend.py'),('MCPDeps/sas_archive_transfer.py','sas_archive_transfer.py')]:
        raw = original(source)
        sources[source] = hashlib.sha256(raw).hexdigest()
        text = raw.decode('utf-8')
        if target == 'session_backend.py':
            text = text.replace("        hdr = conn.recv(8)","        hdr = _recv_exact(conn, 8)")
            text = text.replace("        n = int.from_bytes(hdr, 'big')", "        n = int.from_bytes(hdr, 'big')\n        if n > 256 * 1024 * 1024:\n            raise ValueError('RPC frame exceeds 256 MiB')")
            text = text.replace("        cmd = req.get('cmd')", "        import hmac\n        if not hmac.compare_digest(str(req.get('_token', '')), os.environ['MCP4SAS_PYTHON_RPC_TOKEN']):\n            raise PermissionError('Invalid Python backend token')\n        cmd = req.get('cmd')")
            text = text.replace("        if cmd == 'ping':", "        if cmd == 'close':\n            with lock:\n                sess = sessions.pop(session_id, None)\n                if sess is not None:\n                    sess.endsas()\n                session_macros_loaded.pop(session_id, None)\n                session_macro_bootstrap_warning.pop(session_id, None)\n                session_macro_bootstrap_meta.pop(session_id, None)\n            resp = {'status': 'ok', 'msg': 'closed'}\n        elif cmd == 'ping':")
            helper = '''\ndef _recv_exact(conn, size):\n    chunks = bytearray()\n    while len(chunks) < size:\n        chunk = conn.recv(size - len(chunks))\n        if not chunk:\n            raise EOFError('Incomplete RPC header')\n        chunks.extend(chunk)\n    return bytes(chunks)\n\n'''
            text = text.replace('def handle_client(conn, addr):',helper+'def handle_client(conn, addr):')
            text = text.replace('if SUBMIT_HEARTBEAT_SECONDS <= 0:', "if SUBMIT_HEARTBEAT_SECONDS <= 0 or 'sasiocom' in type(getattr(sess, '_io', None)).__module__:")
            text = text.replace('            t = threading.Thread(target=handle_client, args=(conn, addr), daemon=True)\n            t.start()', '            handle_client(conn, addr)  # Preserve the SAS COM owning thread.')
        (vendor/target).write_text(text,encoding='utf-8',newline='\n')
    directory = original('MCPDeps/SAS_ODA_Directory_Cleanup.pm').decode()
    sas = re.search(r"my \$code=<<'SAS';\n(.*?)\nSAS\n",directory,re.S)[1]+'\n'
    assets = OUT/'assets'
    assets.mkdir(exist_ok=True)
    (assets/'directory_cleanup.sas').write_text(sas,encoding='utf-8')
    runner = original('MCPDeps/SAS_ODA_Runner.pm').decode()
    loader = runner[runner.index('sub _build_targeted_remote_macro_loader'):runner.index('sub _expanded_targeted_remote_macro_names')]
    loader = loader.split('$code .= qq{\n',1)[1].rsplit('\n};',1)[0]
    for old,new in [('primary_dir','PRIMARY_DIR'),('fallback_dir','FALLBACK_DIR'),('include_statement','INCLUDE_STATEMENT'),('required_check','REQUIRED_CHECK'),('name','MACRO_NAME')]:
        loader = loader.replace('$'+old,'__'+new+'__')
    (assets/'targeted_macro.sas').write_text(loader.replace('\\$','$')+'\n',encoding='utf-8')
    sources['MCPDeps/SAS_ODA_Runner.pm'] = hashlib.sha256(runner.encode()).hexdigest()
    sources['MCPDeps/SAS_ODA_Directory_Cleanup.pm'] = hashlib.sha256(directory.encode()).hexdigest()
    (OUT/'SOURCE_PROVENANCE.json').write_text(json.dumps(dict(baseline=BASELINE,sources=sources,backend_changes=['Authenticated loopback RPC','Read complete frame header','Limit RPC frame size','Close a named SAS session explicitly','Serial RPC execution and same-thread COM submit']),indent=2)+'\n',encoding='utf-8')
    mapping = {
        'server.pl':'server.py','run_sas_codes_or_files_in_ODA.pl':'run_sas_codes_or_files_in_ODA.py',
        'run_sas_codes_or_script_in_ODA.pl':'run_sas_codes_or_script_in_ODA.py',
        'cleanup_mcp4sas_intermediates.pl':'cleanup_mcp4sas_intermediates.py',
        'tools/profile_sas_source.pl':'tools/profile_sas_source.py',
        'tools/subset_gtex_expression.pl':'tools/subset_gtex_expression.py',
        'examples/poc/run_example.pl':'examples/poc/run_example.py',
        'examples/poc/validate_outputs.pl':'examples/poc/validate_outputs.py',
        'MCPDeps/SAS_Source_Analysis.pm':'MCP4SAS_Use_Python/source_analysis.py',
        'MCPDeps/SAS_Log_Diagnostics.pm':'MCP4SAS_Use_Python/diagnostics.py',
        'MCPDeps/SAS_ODA_Runner.pm':'MCP4SAS_Use_Python/runner.py',
        'MCPDeps/SAS_ODA_Directory_Cleanup.pm':'MCP4SAS_Use_Python/remote_cleanup.py',
        'MCPDeps/SAS_Local_Home.pm':'MCP4SAS_Use_Python/local_home.py',
        'MCPDeps/SAS_Java_Help.pm':'MCP4SAS_Use_Python/java_help.py',
        'MCPDeps/MCP4SAS_Temp.pm':'MCP4SAS_Use_Python/tempfiles.py',
    }
    names = subprocess.check_output(['git','ls-tree','-r','--name-only',BASELINE],cwd=ROOT).decode().splitlines()
    with (OUT/'PORT_INVENTORY.csv').open('w',encoding='utf-8',newline='') as handle:
        writer = csv.DictWriter(handle,fieldnames=['source','source_sha256','bytes','scope','python_target','status'])
        writer.writeheader()
        for name in names:
            if not name.endswith(('.pl','.pm')):
                continue
            raw = original(name)
            target = mapping.get(name,'')
            writer.writerow(dict(source=name,source_sha256=hashlib.sha256(raw).hexdigest(),bytes=len(raw),scope='runtime_or_utility' if target else 'developer_deferred',python_target=target,status='implemented' if target and (ROOT/target).exists() else 'pending' if target else 'deferred_by_author'))

if __name__ == '__main__':
    main()
