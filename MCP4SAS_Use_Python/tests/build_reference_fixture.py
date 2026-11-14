"""Developer-only: capture behavior of the protected Perl implementation.

The runtime does not import this module or require Perl. CI consumes the frozen
reference so the Python tests also work on machines without Perl.
"""
import json
import os
from pathlib import Path
import subprocess
import sys

ROOT=Path(__file__).resolve().parents[2]
CASES=[
    '', 'proc print data=sashelp.class;run;',
    "data x; a='/*';b=\"*/\";run;", "/* %fake */ %real;", '* %fake; %real;',
    '%* %fake; %real;', "x='It''s good';y=\"double \"\"quotes\"\"\";",
    "data x;input a $;datalines;\n%fake ' /* */\n;\nrun;%real;",
    "data x;input a $;cards4;\n';\n;;;;\nrun;%real;",
    'data x;datalines;\n1\n2\n', "x='never closed;", '/* never closed',
    '%let x=%str(unmatched%\'); %real;', '%let x=%nrstr(%fake(a%))); %real;',
    '%unquote(%nrstr(%real()));', '%unquote(%nrstr(%nrstr(%fake())));',
    '%let x=%str(%real());', '%let x=%nrstr(missing;',
    '%let x=%sysfunc(prxmatch(/abc.*/,abc));', '%let x=%sysfunc(prxchange(s/a.*/b/,1,x));',
    "x=\"%str(%\") %real\";", "%include 'a.sas';", "%inc 'a.sas' 'b.sas' / source2;",
    "%include 'Bob''s.sas';", "%include '&root./remote.sas';", "%let x=%nrstr(%include 'fake.sas';);",
    "x='%include fake;';", "x=\"%include 'fake.sas';\";",
    "data _null_;call execute('%include ''a.sas'';');run;%include 'b.sas';",
    "x=dosubl('%include ''a.sas'' ''b.sas'';');", "x=resolve('%real() %include ''inert.sas'';');",
    "call execute('data _null_;call execute(''%include ''''nested.sas'''';'');run;');",
    '%do i=1 %to 2;%end;', '%if 1 %then %do; %put yes; %end;',
    '%if 1 %then %do; %if 2 %then %do; %end; %end;', '%local x; %return; %goto done;',
    '%macro x; %local a; %do i=1 %to 2; %end;%mend;', '%macro x; %put missing end;',
    '%end; %mend; %then %put orphan;', '%let x=1 %put missing semicolon;', '%label: %goto label;',
    'proc format;value age2 1=2;invalue $status3 "a"=1;picture proper 1="x";run;',
    'filename too_long_name "file.tsv"; filename short "x";',
    '/* Ελληνικά */ %include "中文.sas"; %demo;',
]
LOGS=[
    '', 'WARNING: real\nWARNING: real\nNOTE: Division by zero detected.\nid=1 _ERROR_=1',
    "=== Submission Preflight ===\nWARNING: fake\n=== SAS Log ===\n22 put 'WARNING: fake';\nWARNING: real\nNOTE: Invalid data for x.\n=== Output ===\nWARNING: fake",
    'ERROR: Open code statement recursion detected.\nWARNING: Apparent symbolic reference X not resolved.\nWARNING: Apparent invocation of macro FOO not resolved.',
    'NOTE: Variable x is uninitialized.\nNOTE: Numeric values have been converted to character values.\nNOTE: No observations in data set WORK.X.',
]
FUNCTIONS=['analyze_source','analyze_inline_data','macro_dependency_view','include_targets','open_code_macro_issues','format_name_issues','fileref_name_issues']
PERL=r'''
use JSON::PP; use SAS_Source_Analysis; use SAS_Log_Diagnostics; use SAS_Local_Home; use SAS_ODA_Directory_Cleanup;
my $p=decode_json(do {local $/;<STDIN>});my @r;
for my $t (@{$p->{cases}}){my %row;for my $f (@{$p->{functions}}){no strict 'refs';$row{$f}=&{'SAS_Source_Analysis::'.$f}($t);}push @r,\%row;}
my @logs=map {SAS_Log_Diagnostics::summarize($_)} @{$p->{logs}};
my @cleanup=map {SAS_ODA_Directory_Cleanup::build_code(%$_)} @{$p->{cleanup}};
print JSON::PP->new->utf8->canonical->encode({source=>\@r,logs=>\@logs,cleanup=>\@cleanup});
'''

def main():
    perl=sys.argv[1] if len(sys.argv)>1 else 'perl'
    env=dict(os.environ)
    if os.name=='nt' and Path(perl).is_file():
        env['PATH']=str(Path(perl).parent)+os.pathsep+env.get('PATH','')
    cleanup=[dict(parent='~',names=['owned'],dry_run=1),dict(parent='~/tmp',patterns=['^case_[0-9]+$'],dry_run=0)]
    payload=dict(cases=CASES,logs=LOGS,functions=FUNCTIONS,cleanup=cleanup)
    result=subprocess.run([perl,'-IMCPDeps','-e',PERL],input=json.dumps(payload,ensure_ascii=False).encode(),cwd=ROOT,env=env,capture_output=True,check=True)
    expected=json.loads(result.stdout)
    fixture=dict(baseline='796c37b39e5c3017493de227b244413f8e684141',**payload,expected=expected)
    directory=Path(__file__).parent/'fixtures'
    directory.mkdir(exist_ok=True)
    (directory/'perl_reference.json').write_text(json.dumps(fixture,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(f'Captured {len(CASES)*len(FUNCTIONS)} lexical, {len(LOGS)} diagnostic and {len(cleanup)} cleanup references from original Perl modules.')

if __name__=='__main__':
    main()
