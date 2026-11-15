"""Native counterparts of SAS_Evaluation_Corpus.pm and SAS_Evaluation_Log.pm.

Source hashes and oracle hashes are separate. Runtime assertions must appear in
the runtime log, never in echoed source or HTML. Expected SAS errors must not be
confused with transport, timeout, disk-quota, or remote-session failures.
"""
from collections import Counter
import hashlib
import json
import re


def contract_fingerprint(case):
    contract=dict(expected_failure=int(bool(case.get('expected_failure'))),
                  expected=case.get('expected'),diagnostic=case.get('diagnostic') or '',
                  tolerance=case.get('tolerance','1e-9'))
    if case.get('warning_pattern'):contract['warning_pattern']=case['warning_pattern']
    if case.get('policy_failure'):contract['policy_failure']=1
    return hashlib.sha256(json.dumps(contract,sort_keys=True,separators=(',',':'),ensure_ascii=False).encode()).hexdigest()


def checked_contract(case,recorded):
    if recorded is None:return False
    if recorded!=contract_fingerprint(case):
        raise ValueError(f"Evaluation contract mismatch {case['id']}; rerun against the reviewed manifest")
    return True


def select_cases(manifest,only=None):
    cases=manifest.get('cases') if isinstance(manifest,dict) else None
    count=manifest.get('count') if isinstance(manifest,dict) else None
    if not isinstance(cases,list) or not isinstance(count,int) or isinstance(count,bool) or count<=0 or len(cases)!=count:
        raise ValueError('Invalid corpus manifest')
    known=set()
    for case in cases:
        if (not isinstance(case,dict) or not re.fullmatch(r'[A-Z]\d{3,4}',case.get('id',''))
            or case.get('file')!=case['id']+'.sas' or not re.fullmatch(r'[a-fA-F0-9]{64}',case.get('body_sha256',''))):
            raise ValueError('Invalid case metadata')
        if case['id'] in known:raise ValueError('Duplicate manifest ID '+case['id'])
        known.add(case['id'])
        if case.get('expected_failure') and not case.get('diagnostic'):
            raise ValueError('Missing expected-error diagnostic '+case['id'])
        if not case.get('expected_failure') and case.get('expected') is None:
            raise ValueError('Missing numerical oracle '+case['id'])
    if not only:return list(cases)
    selected=set()
    for value in only.split(','):
        value=value.strip()
        if not value:raise ValueError('Empty selected ID')
        if value in selected:raise ValueError('Duplicate selected ID '+value)
        if value not in known:raise ValueError('Unknown selected ID '+value)
        selected.add(value)
    return [case for case in cases if case['id'] in selected]


def normalized(source):
    return re.sub(r'\r\n?', '\n',source)


def checked_source(case,source):
    if not source:raise ValueError('Missing program '+case['id'])
    canonical=re.sub(r'\A/\*[^\n]*\*/\n','',normalized(source))
    letter=case['id'][0]
    if letter=='L':canonical=re.sub(r'L\d{3}','LCASE',canonical)
    elif letter=='R':canonical=re.sub(r'r\d{3,4}','rCASE',canonical,flags=re.I)
    else:canonical=re.sub(re.escape(letter)+r'\d{4}',letter.lower()+'CASE',canonical,flags=re.I)
    if hashlib.sha256(canonical.encode()).hexdigest()!=case['body_sha256'].lower():
        raise ValueError('Program body hash mismatch '+case['id']+'; rebuild/review the manifest before executing changed fixtures')
    return source


def behavior_fingerprint(case,source):
    checked_source(case,source)
    source=re.sub(r'\A/\*[^\n]*\*/\n','',normalized(source))
    source=re.sub(re.escape(case['id']),'CASE',source,flags=re.I)
    source=re.sub(r'\b(?:LIB500|ROUND\d+)_(PASS|FAIL|ROWS)=',r'EVAL_\1=',source)
    return hashlib.sha256(source.encode()).hexdigest()


def evaluate(*,report,marker,expected=(),exit_code=None,expected_failure=False,
             diagnostic=None,status=None,require_status=False,policy_failure=False,warning_pattern=None):
    match=re.search(r'^=== SAS Log ===\r?\n(.*?)(?:\r?\n=== Output ===|\Z)',report,re.M|re.S)
    log=match[1] if match else ''
    expected=set(expected)
    counts=Counter();unexpected=[];errors=[];warnings=[]
    for line in log.splitlines():
        assertion=re.fullmatch(re.escape(marker)+r'=(\S+)[ \t]*',line)
        if assertion:
            identifier=assertion[1];counts[identifier]+=1
            if identifier not in expected:unexpected.append(identifier)
        if re.match(r'^\s*ERROR(?:\s+\d+-\d+)?:',line,re.I):errors.append(line)
        if re.match(r'^\s*WARNING(?:\s+\d+-\d+)?:',line,re.I):warnings.append(line)
    status=status if isinstance(status,dict) else {}
    failure_class=status.get('failure_class','')
    infrastructure=bool(re.fullmatch(r'sas_oda_(?:space_exhaustion|remote_session_termination)|sas_windows_network_path_unavailable',failure_class)
        or any(re.match(r'^\s*ERROR:\s+Windows error code:\s*67 in hx_disk_access\b',v,re.I) for v in errors)
        or exit_code in (73,74) or re.fullmatch(r'timeout|timed_out',status.get('state',''),re.I)
        or re.search('timeout',failure_class,re.I) or re.search(r'\btimed\s+out\b',status.get('message',''),re.I))
    matched=False
    if expected_failure:
        if len(expected)!=1 or not diagnostic:
            raise ValueError('Expected-failure evaluation requires one case and a diagnostic pattern')
        matched=any(re.search(diagnostic,v,re.I) for v in errors)
        passes={v:bool(match and exit_code==1 and not infrastructure and matched and not counts) for v in expected}
    else:
        if policy_failure and not warning_pattern:
            raise ValueError('Policy-failure evaluation requires an explicit warning pattern')
        wanted=1 if policy_failure else 0
        passes={v:bool(match and exit_code==wanted and not infrastructure and not errors and not unexpected and counts[v]==1) for v in expected}
    warning_match=bool(warning_pattern and any(re.search(warning_pattern,v,re.I) for v in warnings))
    if warning_pattern and not warning_match:passes={v:False for v in passes}
    status_valid=True
    if require_status:
        status_valid=bool(status.get('complete') and status.get('success') is not None
            and ((status.get('state')=='failed' and not status['success']) if expected_failure or policy_failure
                 else (status.get('state')=='completed' and status['success'])))
        if not status_valid:passes={v:False for v in passes}
    return dict(has_runtime_log=bool(match),counts=dict(counts),errors=errors,unexpected=unexpected,passes=passes,
                diagnostic_match=matched,warning_match=warning_match,status_valid=status_valid,infrastructure_failure=infrastructure)
