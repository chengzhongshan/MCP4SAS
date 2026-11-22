#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../MCPDeps";
use SAS_ODA_Runner;
use File::Temp qw(tempdir);
use File::Path qw(make_path);
use File::Copy qw(copy);
use File::Spec;
use Cwd qw(getcwd abs_path);
use IPC::Open3;
use Symbol qw(gensym);
use JSON::PP qw(decode_json);
use Test::More;

my $python=$ENV{PIPELINE_PYTHON_BIN} || 'python3';
open my $py,'-|',$python,'-c','import sys; print(sys.executable)' or die $!;
my $executable=<$py>;close $py or die 'Python executable probe failed';
$executable =~ s/[\r\n]+\z//;$executable =~ s{\\}{/}g;
my $fixture=tempdir('saspy discovery XXXX',TMPDIR=>1,CLEANUP=>1);
make_path("$fixture/MCPDeps","$fixture/.venv-pipeline");
for my $file (glob "$Bin/../MCPDeps/*.pm") {copy($file,"$fixture/MCPDeps/") or die $!;}
for my $entry(qw(run_sas_codes_or_script_in_ODA.pl run_sas_codes_or_files_in_ODA.pl)) {
    copy("$Bin/../$entry","$fixture/$entry") or die $!;
}
open my $f,'>:raw',"$fixture/.venv-pipeline/.python-bin" or die $!;
print {$f} "$executable\r\n";close $f;
open $f,'>',"$fixture/saspy.py" or die $!;
print {$f} <<'PY';
from types import SimpleNamespace
class SASsession:
    def __init__(self, **kwargs):
        self._io=SimpleNamespace(pid=777,sascfg=SimpleNamespace(iomhost=['fixture.invalid'],omruser='fixture',authkey=''))
    def submit(self, code, **kwargs): return {'LOG':'NOTE: DISCOVERY_SUBMIT_OK\n','LST':'<!DOCTYPE html><html><head><title>Discovery fixture</title></head><body><table><tr><th>Result</th></tr><tr><td>DISCOVERY_TABLE</td></tr></table></body></html>'}
    def symget(self, name): return 'fixture'
    def dirlist(self, path): return ['DISCOVERY_FILE.sas']
    def saslog(self): return 'NOTE: DISCOVERY_SUBMIT_OK'
    def endsas(self): pass
PY
close $f;
open $f,'>',"$fixture/probe.pl" or die $!;
print {$f} <<'PL';
use strict; use warnings; use FindBin qw($Bin); use lib "$Bin/MCPDeps";
use SAS_ODA_Runner;use JSON::PP qw(encode_json);
print encode_json({python=>$ENV{PIPELINE_PYTHON_BIN}//'',pythonpath=>$ENV{PYTHONPATH}//''});
PL
close $f;
my $cwd=getcwd();chdir $fixture or die $!;
local $ENV{PIPELINE_PYTHON_BIN};delete $ENV{PIPELINE_PYTHON_BIN};
local $ENV{PYTHONPATH}=SAS_ODA_Runner::_normalize_local_path_for_python($fixture,$python);
local $ENV{SASPY_CFGNAME}='discovery_fixture';local $ENV{SASPY_CFGFILE}='';
local $ENV{SAS_LOCAL_HOME_DIR}='';
local $ENV{PIPELINE_SKIP_SAS_ODA_AUTH_BOOTSTRAP}=1;
local $ENV{SAS_ODA_AUTOLOAD_MACROS}=0;local $ENV{PERLMCP_SASPY_LOAD_MACROS}=0;
local $ENV{OPEN_RESULT}=0;
sub execute {
    my $err=gensym;
    my $pid=open3(my $in,my $out,$err,$^X,@_);close $in;
    my $text=(do{local$/;<$out>} // '').(do{local$/;<$err>} // '');
    waitpid($pid,0);return ($?>>8,$text);
}
my ($exit,$text)=execute('probe.pl');
is($exit,0,'bootstrap accepts a CRLF interpreter record');
my $selected=decode_json($text);
is($selected->{python},$executable,'SASPy-capable recorded interpreter selected instead of unrelated PATH Python');
unlike($selected->{python},qr/[\r\n]/,'record line endings never enter executable path');
for my $entry(qw(run_sas_codes_or_files_in_ODA.pl run_sas_codes_or_script_in_ODA.pl)) {
    for my $case (['submit','--code','proc print data=sashelp.class;run;'],['listing','--dir4listing','~']) {
        ($exit,$text)=execute($entry,@$case[1,2],'--output-prefix',"$fixture/$entry-$case->[0]",'--run-timeout-seconds','30');
        is($exit,0,"$entry $case->[0] executes with discovered Python and isolated SASPy fixture");
        unlike($text,qr/ModuleNotFoundError|No module named|unknown .*Python helper failure/,'no missing-SASPy traceback');
        if($case->[0] eq 'submit') {
            my ($html)=$text =~ /^HTML output saved to: ([^\r\n]+)/m;
            ok(defined($html) && -s $html,'submission saves the reported HTML result') or diag($text);
        } else {like($text,qr/DISCOVERY_FILE\.sas/,'file listing returns the fixture result');}
    }
}
chdir $cwd or die $!;
done_testing;
