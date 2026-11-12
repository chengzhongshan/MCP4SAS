#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../MCPDeps";
use SAS_ODA_Runner;
use Test::More;
use File::Temp qw(tempdir);
use File::Spec;

# Exercise real filesystem I/O through the selected Python, not just strings.
my $python=$ENV{PIPELINE_PYTHON_BIN} || 'python3';
my $dir=tempdir('python path boundary XXXX',TMPDIR=>1,CLEANUP=>1);
my $source=File::Spec->catfile($dir,'input with spaces.txt');
my $result=File::Spec->catfile($dir,'result with spaces.txt');
open my $fh,'>',$source or die $!;
print {$fh} "path boundary ok\n"; close $fh;
my $source_arg=SAS_ODA_Runner::_normalize_local_path_for_python($source,$python);
my $result_arg=SAS_ODA_Runner::_normalize_local_path_for_python($result,$python);
my $status=system {$python} $python,'-c',
    'import pathlib,sys; pathlib.Path(sys.argv[2]).write_bytes(pathlib.Path(sys.argv[1]).read_bytes())',
    $source_arg,$result_arg;
is($status,0,'selected Python reads and writes actual paths containing spaces');
open my $read,'<',$result or die $!;
is(do {local $/; <$read>},"path boundary ok\n",'Perl reads the result written by Python'); close $read;
my $args={uploads=>[{local_path=>$source}],download_local_path=>$result,remote_path=>'~/keep_this'};
my $converted=SAS_ODA_Runner::_normalize_python_action_args($args,$python);
is($converted->{uploads}[0]{local_path},$source_arg,'upload path uses the same interpreter boundary');
is($converted->{download_local_path},$result_arg,'download destination uses the same interpreter boundary');
is($converted->{remote_path},'~/keep_this','remote SAS path is preserved');
is($args->{uploads}[0]{local_path},$source,'normalization does not mutate caller input');

my $nested=SAS_ODA_Runner::_normalize_python_action_args({cmd=>'bulk_transfer',payload=>{uploads=>[{local_path=>$source}],downloads=>[{local_path=>$result,remote_path=>'~/remote'}]}},$python);
is($nested->{payload}{uploads}[0]{local_path},$source_arg,'nested bulk upload path normalized');
is($nested->{payload}{downloads}[0]{local_path},$result_arg,'nested bulk download path normalized');
is($nested->{payload}{downloads}[0]{remote_path},'~/remote','nested remote path preserved');
SKIP: {
    skip 'Cygwin POSIX Python control requires Cygwin',2 unless $^O eq 'cygwin' && -x '/usr/bin/python3';
    my $posix_arg=SAS_ODA_Runner::_normalize_local_path_for_python($source,'/usr/bin/python3');
    is(system('/usr/bin/python3','-c','import pathlib,sys; assert pathlib.Path(sys.argv[1]).read_bytes()==b"path boundary ok\n"',$posix_arg),0,
       'Cygwin Python still reads the same file using POSIX paths');
    ok(!SAS_ODA_Runner::_python_uses_windows_paths('/usr/bin/python3'),'POSIX interpreter is not classified by the Perl platform');
}
done_testing();
