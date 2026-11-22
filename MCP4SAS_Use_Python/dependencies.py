"""Discover a local macro/include graph before connecting to SAS.

SAS built-ins and quoted DATA values are not macro dependencies. Missing local
paths remain SAS/server paths. Conflicting upload basenames fail before transfer.
"""
from pathlib import Path
import os
import re
from . import source_analysis as source

def read_source(path):
    raw=Path(path).read_bytes()
    try:
        return raw.decode('utf-8-sig')
    except UnicodeDecodeError:
        return raw.decode('latin-1')

def resolve_local(value,roots):
    if value.startswith('~/') and Path(value).suffix.lower()=='.sas':
        # Bundled macro includes use a remote-home spelling. Prefer an exact
        # local dependency file, without recursively traversing the workspace.
        name=Path(value).name
        for root in roots:
            for directory in ('MCPDeps','DiffGWASDeps'):
                candidate=Path(root)/directory/name
                if candidate.is_file():
                    return candidate.resolve()
        return None
    if not source.is_local_file_candidate(value) or source.include_target_needs_runtime_resolution(value) or value.startswith(('~/','/home/','http://','https://')):
        return None
    path=Path(value)
    choices=[path] if path.is_absolute() else [Path(root)/path for root in roots]
    for candidate in choices:
        if candidate.is_file():
            return candidate.resolve()
    return None

def find_macro(name,roots):
    if source.is_builtin_macro_name(name):
        return None
    wanted=name+'.sas'
    directories=[]
    for root in roots:
        for directory in (Path(root),Path(root)/'Macros'):
            if directory.is_dir() and directory not in directories:
                directories.append(directory)
    # Path.is_file() on macOS's usual case-insensitive volume accepts a
    # differently cased spelling; Path.resolve() does not restore its basename.
    # Inspect actual directory entries so uploaded names retain their spelling.
    entries=[(directory,[p for p in directory.iterdir() if p.is_file()]) for directory in directories]
    for directory,files in entries:
        exact=next((p for p in files if p.name==wanted),None)
        if exact is not None:
            return exact.resolve()
    for directory,files in entries:
        found=[p for p in files if p.name.casefold()==wanted.casefold()]
        if len(found)>1:
            raise ValueError(f'Ambiguous case-insensitive macro source: {name} in {directory}')
        if found:
            return found[0].resolve()
    return None

def macro_calls(text,analysis=None):
    view=source.macro_dependency_view(text,analysis)
    definitions={m[1].casefold() for m in re.finditer(r'%macro\s+([A-Za-z_]\w*)\b',view,re.I)}
    names=[]
    for match in re.finditer(r'%([A-Za-z_]\w*)\b',view):
        name=match[1]
        if source.is_builtin_macro_name(name) or name.casefold() in definitions or re.match(r'\s*:',view[match.end():]):
            continue
        if name.casefold() not in {n.casefold() for n in names}:
            names.append(name)
    return names

def data_paths(text,analysis=None):
    analysis=analysis if analysis is not None else source.analyze_source(text)
    pattern=r'''\b(datafile\s*=\s*|zip\s*=\s*|infile\s+|filename\s+\S+\s+)(["'])(.*?)\2'''
    for match in re.finditer(pattern,analysis['comments_masked'],re.I|re.S):
        if analysis['masked'][match.start():match.start()+len(match[1])].strip():
            yield match[3]
    for match in re.finditer(r'\b(?:datafile|zip)\s*=\s*([^\s,;)\r\n]+)',analysis['comments_masked'],re.I):
        if not match[1].startswith(('"',"'")) and analysis['masked'][match.start():match.start()+4].strip():
            yield match[1]

def rewrite_paths(code,mapping):
    # Mask comments and inline cards, including their path-like text.
    visible=source.mask_comments(code)
    replacements=[]
    for local,remote in mapping.items():
        if local==remote:
            continue
        # SAS doubles quotes once per surrounding literal. Deferred CALL EXECUTE
        # or DOSUBL includes may therefore contain four apostrophes. Match the
        # corresponding spelling without altering the decoded filename.
        pending=[(local,remote)];seen=set()
        while pending:
            spelling,target=pending.pop()
            if spelling in seen or len(spelling)>len(code):continue
            seen.add(spelling)
            for match in re.finditer(re.escape(spelling),visible):
                before=visible[match.start()-1:match.start()] if match.start() else ''
                after=visible[match.end():match.end()+1]
                # Unquoted macro input parameters use =path, or (path).
                # Discovery already recognizes zip=/local/file.gz; leaving
                # that alias unchanged after upload makes SAS use a local
                # Windows path on its Linux server.
                if (before in ("'",'"',' ','\t','\n','\r','=',',','(') or not before) and (after in ("'",'"',';',')',',',' ','\t','\n','\r') or not after):
                    replacements.append((match.start(),match.end(),target))
            for quote in ("'",'"'):
                escaped=spelling.replace(quote,quote*2)
                if escaped!=spelling:pending.append((escaped,target.replace(quote,quote*2)))
    # Compute all spans against original source, then apply once. A remote path
    # containing the local alias must not be rewritten a second time.
    accepted=[]
    for candidate in sorted(set(replacements),key=lambda v:(-(v[1]-v[0]),v[0])):
        if not any(candidate[0]<end and start<candidate[1] for start,end,_ in accepted):accepted.append(candidate)
    for start,end,value in sorted(accepted,reverse=True):
        code=code[:start]+value+code[end:]
    return code

def targeted_loader(names):
    expanded=[]
    for name in names:
        expanded.append('Del_Dir_Recursive' if name.casefold()=='del_dir_recursive' else name)
    template=(Path(__file__).parent/'assets/targeted_macro.sas').read_text(encoding='utf-8')
    code,seen=[],set()
    for name in expanded:
        if source.is_builtin_macro_name(name) or name.casefold() in seen or not re.fullmatch(r'[A-Za-z_]\w*',name):
            continue
        seen.add(name.casefold())
        if name.casefold()=='macroparas':
            portable=Path(__file__).resolve().parent.parent/'examples/sas_macros/macroparas_portable.sas'
            code.append('/* MCP4SAS portable macroparas fallback */\n'+read_source(portable))
            continue
        primary,fallback=('&_macro_home','&_home') if name.casefold()=='del_dir_recursive' else ('&_home','&_macro_home')
        replacements=dict(PRIMARY_DIR=primary,FALLBACK_DIR=fallback,MACRO_NAME=name,INCLUDE_STATEMENT='%include "%superq(_pipeline_targeted_macro_path)";',REQUIRED_CHECK='%if not %sysmacexist(Del_Dir_Recursive) %then %put ERROR: Remote Del_Dir_Recursive macro could not be loaded;\n' if name.casefold()=='del_dir_recursive' else '')
        code.append(re.sub(r'__([A-Z_]+)__',lambda m:replacements[m[1]],template))
    return ('%let _home=%sysfunc(pathname(HOME));\n%let _macro_home=%sysfunc(pathname(HOME))/Macros;\n'+'\n'.join(code)) if code else ''

class Plan:
    def __init__(self,code,source_file=None,macro_dir=None,uploads=()):
        self.code=code
        self.roots=[Path(source_file).resolve().parent] if source_file else []
        self.macro_dir_warning=''
        if macro_dir:
            directory=Path(macro_dir)
            accessible=directory.is_dir()
            if accessible:
                try:
                    with os.scandir(directory):
                        pass
                except OSError:
                    accessible=False
            if accessible:
                self.roots.append(directory.resolve())
            else:
                cwd=Path.cwd().resolve()
                self.macro_dir_warning=f'WARNING: --macro-dir {str(directory)!r} is not reachable; using the current working directory {str(cwd)!r} instead.'
        self.roots.append(Path.cwd())
        self.files={}
        self.texts={}
        self.aliases={}
        self.macros=[]
        self.remote_macros=[]
        self.visiting=set()
        self.visited=set()
        self.definitions=set()
        for path in uploads:
            path=Path(path).resolve(strict=True)
            if not path.is_file():
                raise ValueError(f'Upload is not a file: {path}')
            self.add(path,str(path))
        self.analysis=source.analyze_source(code)
        self.scan(code,self.roots,self.analysis)
        self.remote_macros=[name for name in self.remote_macros if name.casefold() not in self.definitions]

    def add(self,path,alias):
        path=path.resolve()
        name=path.name
        if name in self.files and self.files[name]!=path:
            raise ValueError(f'Two uploads have the same remote basename {name}: {self.files[name]} and {path}')
        if re.search(r'[&%\r\n\x00]',name):
            raise ValueError(f'Upload basename contains SAS macro/control characters: {name}')
        self.files[name]=path
        self.aliases[alias]=path
        self.aliases[str(path)]=path

    def visit(self,path,roots,macro=False):
        if path in self.visiting:
            raise ValueError(f'Cyclic local SAS include/macro dependency: {path}')
        if path in self.visited:
            return
        self.visiting.add(path)
        text=read_source(path)
        self.texts[path]=text
        self.scan(text,[path.parent]+roots)
        self.visiting.remove(path)
        self.visited.add(path)
        if macro and path not in self.macros:
            self.macros.append(path)

    def scan(self,text,roots,analysis=None):
        analysis=analysis if analysis is not None else source.analyze_source(text)
        self.definitions.update(name.casefold() for name in re.findall(r'%macro\s+([A-Za-z_]\w*)\b',source.macro_dependency_view(text,analysis),re.I))
        for alias in source.include_targets(text,analysis):
            path=resolve_local(alias,roots)
            if path:
                self.add(path,alias)
                self.visit(path,roots)
        for name in macro_calls(text,analysis):
            # An explicitly included definition is authoritative, including a
            # user's original macroparas. Do not insert a replacement for it.
            if name.casefold() in self.definitions:
                continue
            path=find_macro(name,roots)
            if path:
                self.add(path,str(path))
                self.visit(path,roots,macro=True)
            elif name.casefold() not in {n.casefold() for n in self.remote_macros}:
                self.remote_macros.append(name)
        for alias in data_paths(text,analysis):
            path=resolve_local(alias,roots)
            if path:
                self.add(path,alias)

    def as_dict(self):
        result=dict(uploads=[str(p) for p in self.files.values()],local_macros=[str(p) for p in self.macros],remote_macros=self.remote_macros,include_files=[str(p) for p in self.texts],source_file_count=len(self.texts))
        if self.macro_dir_warning:
            result['macro_dir_warning']=self.macro_dir_warning
        return result

    def prepare(self,scratch,home,skip_if_same=True):
        mapping={alias:home.rstrip('/')+'/'+path.name for alias,path in self.aliases.items()}
        staged=[]
        for index,path in enumerate(self.files.values()):
            if path in self.texts:
                directory=Path(scratch)/f'source_{index}'
                directory.mkdir()
                local=directory/path.name
                local.write_text(rewrite_paths(self.texts[path],mapping),encoding='utf-8')
            else:
                local=path
            staged.append(dict(local_path=str(local),skip_if_same=skip_if_same and path not in self.texts))
        header=targeted_loader(self.remote_macros)
        for path in self.macros:
            remote=home.rstrip('/')+'/'+path.name
            header+='\n%include "'+remote.replace('"','""')+'";\n'
        return header+'\n'+rewrite_paths(self.code,mapping),staged
