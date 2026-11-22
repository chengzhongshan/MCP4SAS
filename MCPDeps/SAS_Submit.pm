package SAS_Submit;
use strict;
use warnings;

sub python_setup {
    return <<'PY';

def submit_user_code(sess, code):
    import hashlib
    import os
    import tempfile
    import uuid
    raw = code.encode('utf-8')
    threshold = int(os.environ.get('MCP4SAS_STAGE_SOURCE_BYTES', '32768'))
    work = str(getattr(sess, 'workpath', '') or '')
    if threshold <= 0 or len(raw) < threshold or not work:
        return sess.submit(code)
    cfg = getattr(getattr(sess, '_io', None), 'sascfg', None)
    local = cfg is not None and not (getattr(cfg, 'iomhost', None) or getattr(cfg, 'ssh', None))
    token = uuid.uuid4().hex
    ref = 'm' + token[:7]
    digest = hashlib.sha256(raw).hexdigest()
    with tempfile.TemporaryDirectory(prefix='mcp4sas-submit-') as directory:
        source = os.path.join(directory, 'submitted.sas')
        with open(source, 'wb') as handle:
            handle.write(raw)
        if local:
            target = source.replace('\\', '/')
        else:
            target = work.rstrip('/\\') + '/mcp4sas_source_' + token + '.sas'
            uploaded = sess.upload(source, target, overwrite=True)
            if not uploaded or not uploaded.get('Success'):
                raise IOError('Cannot stage large SAS source; user code was not submitted')
        quoted = "'" + target.replace("'", "''") + "'"
        # A short command avoids sending/echoing an entire macro library through
        # IOM's interactive submission channel. Execute once in the same WORK.
        stub = f'''filename {ref} {quoted} encoding='utf-8';
data _null_;
  f=fopen('{ref}','I',1,'B');
  if f<=0 then do; put 'ERROR: MCP4SAS staged source cannot be opened.'; abort cancel; end;
  n=input(compress(finfo(f,'File Size (bytes)'),' ,'),best32.);
  if missing(n) then n=input(compress(finfo(f,'File Size'),' ,'),best32.);
  r=fclose(f);
  if n ne {len(raw)} then do; put 'ERROR: MCP4SAS staged source size mismatch.'; abort cancel; end;
run;
%include {ref};
'''
        if not local:
            stub += f"filename {ref} {quoted}; data _null_; r=fdelete('{ref}'); run;\n"
        stub += f'filename {ref} clear;\n'
        result = sess.submit(stub)
        result = dict(result or {})
        result['LOG'] = ('NOTE: MCP4SAS staged source bytes=' + str(len(raw)) +
                         ' sha256=' + digest + ' transport=' + ('local-file' if local else 'SASPy-upload') +
                         '\n' + str(result.get('LOG', '') or ''))
        return result

PY
}

1;
