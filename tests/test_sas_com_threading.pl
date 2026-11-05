#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../MCPDeps";
use SAS_ODA_Runner;
use Test::More;
use File::Temp qw(tempdir);
use File::Spec;
open my $fh,'<',"$Bin/../MCPDeps/SAS_ODA_Runner.pm" or die $!;
my $source=do {local $/; <$fh>}; close $fh;
my ($submit)=$source =~ /(def _submit_with_heartbeat\(.*?)(?=def _env_truthy)/s;
die 'Cannot find actual submit implementation' unless $submit;
my $dir=tempdir(CLEANUP=>1);
my $script=File::Spec->catfile($dir,'com_threads.py');
open my $out,'>',$script or die $!;
print {$out} "import threading, traceback, time\nSUBMIT_HEARTBEAT_SECONDS=20\n",$submit,<<'PY';
class Session:
    def __init__(self, module):
        self._io=type('IO',(),{'__module__':module})()
        self.owner=threading.get_ident()
        self.called=None
    def submit(self,code):
        self.called=threading.get_ident()
        return {'LOG':'NOTE: '+code}
com=Session('saspy.sasiocom')
assert _submit_with_heartbeat(com,'COM probe')['LOG']=='NOTE: COM probe'
assert com.called==com.owner, 'COM crossed its owning thread'
iom=Session('saspy.sasioiom')
assert _submit_with_heartbeat(iom,'IOM probe')['LOG']=='NOTE: IOM probe'
assert iom.called!=iom.owner, 'IOM lost heartbeat worker behavior'
SUBMIT_HEARTBEAT_SECONDS=0
stdio=Session('saspy.sasiostdio')
_submit_with_heartbeat(stdio,'STDIO probe')
assert stdio.called==stdio.owner
print('COM ownership, IOM heartbeat and disabled-heartbeat contracts passed')
PY
close $out;
my $python=$ENV{PIPELINE_PYTHON_BIN} || 'python3';
my $arg=SAS_ODA_Runner::_normalize_local_path_for_python($script,$python);
is(system({$python} $python,$arg),0,'actual submit implementation keeps COM on its owning thread and preserves IOM heartbeat');
done_testing();
