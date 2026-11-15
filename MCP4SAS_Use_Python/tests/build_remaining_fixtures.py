"""Maintainer-only capture of original Perl source-analysis regression calls.

Generated Python tests replay public API inputs against the native implementation.
This is differential testing, not a replacement for independent live SAS oracles.
No Perl process is used when the published Python counterparts execute.
"""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess

ROOT=Path(__file__).resolve().parents[2]
NAMES=('comment_quote_preflight','deferred_include_paths','deferred_macro_literals',
       'double_quoted_deferred_includes','fileref_name_advisory','format_name_advisory',
       'include_abbreviation','include_file_lists','include_source_order','inline_data_preflight',
       'inline_macro_preflight','literal_execution_contexts','macro_quoting_preflight',
       'open_code_macro_diagnostics','resolve_macro_dependencies','sas_supplied_autocall',
       'unquote_macro_dependencies')


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--perl',required=True);args=p.parse_args()
    scratch=ROOT/'MCP4SAS_Use_Python/test-results/remaining-fixtures';scratch.mkdir(parents=True,exist_ok=True)
    exporter=scratch/'capture.pl'
    exporter.write_text(r'''use strict; use warnings; use JSON::PP; use FindBin;
use lib $ENV{TRACE_DEPS}; use SAS_Source_Analysis;
my @calls; my $depth=0;
for my $name (qw(is_local_file_candidate include_target_needs_runtime_resolution is_builtin_macro_name
 analyze_inline_data mask_inline_data analyze_source mask_noncode open_code_macro_issues mask_comments
 mask_macro_literals macro_dependency_view include_targets format_name_issues fileref_name_issues)) {
    no strict 'refs'; no warnings 'redefine';
    my $original=\&{"SAS_Source_Analysis::$name"};
    *{"SAS_Source_Analysis::$name"}=sub {
        my @args=@_; my $context=wantarray; my (@result,$result);
        my $top=$depth++==0;
        if ($context) {@result=$original->(@args);} else {$result=$original->(@args);}
        --$depth;
        # Snapshot now: later tests populate mutable analysis caches.
        push @calls,JSON::PP::decode_json(JSON::PP::encode_json({function=>$name,arguments=>\@args,list_context=>$context?1:0,result=>$context?\@result:$result})) if $top;
        return $context?@result:$result;
    };
}
$FindBin::Bin=$ENV{TRACE_TESTS};
do $ENV{TRACE_SOURCE}; die $@ if $@;
open my $out,'>:raw',$ENV{TRACE_OUTPUT} or die $!;
print {$out} JSON::PP->new->canonical->encode(\@calls);close $out;
''',encoding='utf-8')
    import os
    fixtures={}
    for name in NAMES:
        source=ROOT/'tests'/('test_'+name+'.pl');output=scratch/(name+'.json')
        env=dict(os.environ,TRACE_DEPS=(ROOT/'MCPDeps').as_posix(),TRACE_TESTS=(ROOT/'tests').as_posix(),
                 TRACE_SOURCE=source.as_posix(),TRACE_OUTPUT=output.as_posix())
        result=subprocess.run([args.perl,exporter.as_posix()],cwd=ROOT,env=env,capture_output=True)
        if result.returncode:raise RuntimeError(source.name+' capture failed: '+result.stderr.decode(errors='replace'))
        calls=json.loads(output.read_text(encoding='utf-8'))
        unique={json.dumps(v,sort_keys=True,separators=(',',':')):v for v in calls}
        if not calls:raise RuntimeError('No native API coverage captured for '+name)
        fixtures[name]=dict(source_file='tests/'+source.name,source_sha256=hashlib.sha256(source.read_bytes()).hexdigest(),calls=list(unique.values()))
        target=ROOT/'tests'/('test_'+name+'.py')
        target.write_text('"""Native Python differential counterpart of '+source.name+'."""\n'
            'import sys\nfrom pathlib import Path\n'
            'sys.path.insert(0,str(Path(__file__).resolve().parents[1]))\n'
            'from MCP4SAS_Use_Python.regression_replay import main\n'
            "if __name__=='__main__':raise SystemExit(main('"+name+"'))\n",encoding='utf-8')
        print(f'{name}: {len(unique)} distinct API vectors',flush=True)
    destination=ROOT/'MCP4SAS_Use_Python/assets/remaining_regressions.json'
    destination.write_text(json.dumps(fixtures,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')


if __name__=='__main__':main()
