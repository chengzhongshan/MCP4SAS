"""Preserve the original guarded SAS directory-cleanup program."""
from pathlib import Path
import re

def sas_literal(value):
    return "'"+value.replace("'","''")+"'"

def exact_name_patterns(names):
    if not names:
        raise ValueError('Directory names must be a nonempty array')
    patterns=[]
    for name in names:
        name=name.rstrip('/')
        if not name or re.search(r'[/\x00-\x1f%&,\'"();\\]',name):
            raise ValueError('Directory name must be an immediate child basename')
        if name in ('.','..','_DELETE_','Macros','._mcp4sas_directory_cleanup_lock'):
            raise ValueError(f'Refusing protected directory name: {name}')
        patterns.append('^'+re.sub(r'([^A-Za-z0-9_-])',r'\\\1',name)+'$')
    return patterns

def build_code(parent='~',patterns=None,names=None,dry_run=False):
    if not re.fullmatch(r'(?:~(?:/.*)?|/.*)',parent) or re.search(r'(?:\A|/)\.\.?(?:/|\Z)|[\x00-\x1f%&,\'"();\\]',parent):
        raise ValueError('Unsafe directory parent')
    parent=parent.rstrip('/')
    if not parent:
        raise ValueError('Cannot scan filesystem root for recursive deletion')
    if patterns is not None and names is not None:
        raise ValueError('Provide patterns or names, not both')
    patterns=exact_name_patterns(names) if names is not None else patterns
    if not patterns:
        raise ValueError('At least one nonempty directory regex is required')
    initial,match=[],[]
    for i,pattern in enumerate(patterns,1):
        if not pattern or re.search(r'[\x00-\x1f]',pattern):
            raise ValueError('Invalid directory regex')
        re.compile(pattern)
        expression,backslashes='',0
        for char in pattern:
            if char=='/' and backslashes%2==0:
                expression+='\\'
            expression+=char
            backslashes=backslashes+1 if char=='\\' else 0
        index=f'{i-1}+1'
        initial.append(f"re[{index}]=prxparse({sas_literal('/(?:'+expression+')/')}); if missing(re[{index}]) then do; put 'ERROR: Invalid directory PRX expression'; call symputx('_mcp_ok',0,'L'); stop; end;")
        match.append(f'prxmatch(re[{index}],trim(name))')
    source=(Path(__file__).parent/'assets/directory_cleanup.sas').read_text(encoding='utf-8')
    replacements=dict(PARENT=sas_literal(parent),REGEX_COUNT=str(len(patterns)),REGEX_INIT='\n '.join(initial),REGEX_MATCH=' or '.join(match),DRY_RUN=str(int(dry_run)),UNSAFE_CHARS=sas_literal('%&,\'"();/\\'))
    source=re.sub(r'__([A-Z_]+)__',lambda m:replacements[m[1]],source)
    if dry_run:
        source=re.sub(r"/\* The user's macro uses.*?%mend;",'%mend;',source,flags=re.S)
    return source
