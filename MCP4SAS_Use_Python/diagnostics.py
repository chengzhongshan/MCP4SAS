"""SAS severity and diagnostic hints; source echoes are not runtime results."""
import re

MACRO_HINTS = [
    (r'open code statement recursion','open_code_recursion','Check for a missing semicolon before the next %LET/%PUT or other macro statement.'),
    (r'not valid in open code|nesting of.*%IF.*open code|%DO.*required|Expected %DO not found','open_code_control','Use a macro wrapper for loops, %LOCAL and nested conditionals; open-code %IF requires supported %THEN/%ELSE %DO groups.'),
    (r'apparent symbolic reference.*not resolved','unresolved_macro_variable','Check spelling, scope, creation timing and the dot delimiter before appended text.'),
    (r'apparent invocation of macro.*not resolved','unresolved_macro_invocation','Define or load the macro before invoking it; verify its source filename and macro name.'),
    (r'recursive reference.*(?:macro|text expression)|text expression.*recursive reference','recursive_macro_reference','Avoid a parameter or variable default that resolves to itself.'),
    (r'(?:macro variable|macro definition|macro .*?).*(?:not found|does not exist|could not be deleted)','missing_macro_symbol','Check %SYMEXIST/%SYSMACEXIST or use the deletion statement NOWARN option for intentional no-ops.'),
    (r'%(?:EVAL|SYSEVALF|SYSFUNC|SUBSTR|SCAN)\b|(?:positional|keyword|duplicate).*parameter','macro_expression','Check macro argument order/quoting and integer operands; use %SYSEVALF for decimal arithmetic.'),
]

def sas_log(text):
    match = re.search(r'=== SAS Log ===\r?\n(.*?)(?:\r?\n=== Output ===|\Z)',text or '',re.S)
    return match[1] if match else text or ''

def summarize(text):
    result = dict(warnings=[],data_quality=[],macro_diagnostics=[])
    seen = set()
    for line in sas_log(text).splitlines():
        line = line.strip()
        if re.match(r'^ERROR:\s+Windows error code:\s*67 in hx_disk_access\b',line,re.I):
            if ('infrastructure',line) not in seen:
                result.setdefault('infrastructure_diagnostics',[]).append(dict(
                    kind='windows_network_path_unavailable',
                    message=line,
                    hint='Windows error 67 means the network name is unavailable. Verify that the UNC share is reachable from the SAS host; check FILENAME, LIBNAME and SASAUTOS settings. --macro-dir controls local discovery and cannot repair server-side paths.',
                ))
                seen.add(('infrastructure',line))
        if re.match(r'^(?:ERROR|WARNING)(?:\s+\d+-\d+)?:',line,re.I):
            for pattern,kind,hint in MACRO_HINTS:
                if re.search(pattern,line,re.I):
                    if ('macro',line) not in seen:
                        result['macro_diagnostics'].append(dict(kind=kind,message=line,hint=hint,severity='error' if line.upper().startswith('ERROR') else 'warning'))
                        seen.add(('macro',line))
                    break
        kind = None
        if re.match(r'^WARNING(?:\s+\d+-\d+)?:',line,re.I):
            kind = 'warnings'
        elif re.search(r'^NOTE:\s+(?:Invalid (?:data|argument)|Variable .+ is uninitialized\.|Division by zero|Mathematical operations could not be performed|Missing values were generated|(?:Character|Numeric) values have been converted|SAS went to a new line when INPUT statement reached past the end of a line|No observations in data set)',line,re.I) or re.search(r'^(?!\d+\s|MPRINT\b|SYMBOLGEN\b|NOTE:).*\b_ERROR_=1\b',line,re.I):
            kind = 'data_quality'
        if kind and (kind,line) not in seen:
            result[kind].append(line)
            seen.add((kind,line))
    result.update(warning_count=len(result['warnings']),data_quality_count=len(result['data_quality']),macro_count=len(result['macro_diagnostics']))
    if result.get('infrastructure_diagnostics'):
        result['infrastructure_count']=len(result['infrastructure_diagnostics'])
    return result

def format_summary(result):
    if not any(result.get(key,0) for key in ('warning_count','data_quality_count','macro_count','infrastructure_count')):
        return ''
    text = f"SAS diagnostics: {result['warning_count']} warning(s), {result['data_quality_count']} data-quality diagnostic(s).\n"
    for kind in ('warnings','data_quality'):
        text += ''.join(f'  {line}\n' for line in result[kind][:3])
    if result['macro_count']:
        text += f"Macro diagnostics: {result['macro_count']}.\n"
        text += ''.join(f"  {item['message']}\n  Hint: {item['hint']}\n" for item in result['macro_diagnostics'][:3])
    if result.get('infrastructure_count'):
        text += f"Infrastructure diagnostics: {result['infrastructure_count']}.\n"
        text += ''.join(f"  {item['message']}\n  Hint: {item['hint']}\n" for item in result['infrastructure_diagnostics'][:3])
    return text+'\n'

def classify(text):
    text = sas_log(text)
    error_lines = re.findall(r'^\s*ERROR(?:\s+\d+-\d+)?:[^\r\n]*',text,re.I|re.M)
    failure, code = '', 0
    runtime_lines=[line for line in text.splitlines() if not re.match(r'^\s*(?:\d+(?:\s+|!\s*)|MPRINT\([^)]*\):|MLOGIC\([^)]*\):|SYMBOLGEN:)',line,re.I)]
    if any(re.search(r'^\s*ERROR:\s+Insufficient space in\b|^\s*ERROR:.*(?:No space left on device|Disk quota exceeded|file system is full|disk is full|quota[^\r\n]*exceed)|^\s*(?:ERROR:\s*)?UNIX errno\s*=\s*(?:28|122)(?:\D|$)',line,re.I) for line in runtime_lines):
        failure, code = 'sas_oda_space_exhaustion',73
    elif any(re.search(r'^\s*ERROR:\s+Windows error code:\s*67 in hx_disk_access\b',line,re.I) for line in runtime_lines):
        failure, code = 'sas_windows_network_path_unavailable',1
    elif any(re.search(r'No SAS process attached|SAS process has terminated unexpectedly|SAS submit returned empty output and the SAS session was no longer usable|session server[^\n]*(?:terminated|closed)|remote SAS[^\n]*(?:terminated|disconnected)',line,re.I) for line in runtime_lines):
        failure, code = 'sas_oda_remote_session_termination',74
    elif error_lines:
        failure, code = 'sas_program_error',1
    elif re.search(r'^\s*WARNING:\s+Apparent invocation of macro\b.*not resolved\.',text,re.I|re.M):
        failure, code = 'sas_macro_resolution_error',1
    return dict(exit_code=code,failure_class=failure,retryable=False,errors=error_lines,**summarize(text))
