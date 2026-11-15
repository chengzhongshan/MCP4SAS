"""Maintainer-only snapshot of unchanged Perl example catalogs and test inputs.

Perl is used only to evaluate the original catalogs at snapshot-build time. All
published Python demos read the resulting JSON and run without Perl.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess

ROOT=Path(__file__).resolve().parents[2]
DATA=ROOT/'MCP4SAS_Use_Python/assets'
CATALOGS=['run_live_new_examples_30.pl','new_examples_31_60.pl',
          'new_examples_61_90.pl','new_examples_91_190.pl',
          'new_examples_191_290.pl','new_examples_291_390.pl',
          'new_examples_391_490.pl','new_examples_491_590.pl']

def build(perl):
    scratch=ROOT/'MCP4SAS_Use_Python/test-results/homepage-fixtures'
    scratch.mkdir(parents=True,exist_ok=True)
    source=(ROOT/'tests'/CATALOGS[0]).read_text(encoding='utf-8')
    block=source[source.index('my @cases;'):source.index('if ($batch >= 2) {')]
    export="use strict; use warnings; use JSON::PP;\n"+block+"\nmy @all=(\\@cases);\n"
    for name in CATALOGS[1:]:
        path=(ROOT/'tests'/name).as_posix().replace("'","\\'")
        export+=f"push @all,do '{path}'; die $@ if $@;\n"
    export+='print JSON::PP->new->canonical->encode(\\@all);\n'
    script=scratch/'export.pl'
    script.write_text(export,encoding='utf-8')
    batches=json.loads(subprocess.check_output([perl,str(script)],cwd=ROOT))
    inputs={name:hashlib.sha256((ROOT/'tests'/name).read_bytes()).hexdigest() for name in CATALOGS}
    assert [len(items) for items in batches]==[30,30,30,100,100,100,100,100]
    report=dict(source_commit=subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),
                source_files=inputs,batches=batches)
    (DATA/'example_catalogs.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    adversarial=ROOT/'tests/new_validation_tasks_001_100.pl'
    text=adversarial.read_text(encoding='utf-8')
    names=['include_cases','format_cases','fileref_cases','diagnostic_cases']
    blocks=[re.search(r'my @'+name+r' = \(.*?\n\);',text,re.S)[0] for name in names]
    export='use strict; use warnings; use JSON::PP;\n'+'\n'.join(blocks)
    export+='\nprint JSON::PP->new->canonical->encode({'+','.join(f"'{n}'=>\\@{n}" for n in names)+'});\n'
    script.write_text(export,encoding='utf-8')
    cases=json.loads(subprocess.check_output([perl,str(script)],cwd=ROOT))
    cases['source_sha256']=hashlib.sha256(adversarial.read_bytes()).hexdigest()
    (DATA/'adversarial_cases.json').write_text(json.dumps(cases,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print('Captured 590 unchanged SAS examples and 75 original adversarial input/expectation records')

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--perl',required=True)
    build(parser.parse_args().perl)
