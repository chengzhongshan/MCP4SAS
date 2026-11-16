#!/usr/bin/env perl
use strict; use warnings;
use FindBin qw($Bin);
use File::Spec;
use Test::More;
my $source=File::Spec->catfile($Bin,'..','examples','sas_macros','macroparas_portable.sas');
open my $fh,'<',$source or die $!;
my $text=do {local $/; <$fh>}; close $fh;
like($text,qr/%macro macroparas\(/i,'portable macro preserves the public entry point');
unlike($text,qr/stjude\.sjcrh|H:\\F_Queens/i,'no personal network share or drive default');
unlike($text,qr/%abort/i,'no session-wide abort on an empty match');
like($text,qr/filename\(ref\)/,'source filerefs are released');
like($text,qr/MACROPARAS_MATCH_COUNT/,'search count is observable');
done_testing;
# Reuse the same scientific assertions with the actual Perl runner when opted in.
if (grep {$_ eq '--live'} @ARGV) {
    my $python=$ENV{PIPELINE_PYTHON_BIN} || 'python3';
    require lib; lib->import(File::Spec->catdir($Bin,'..','MCPDeps'));
    require SAS_ODA_Runner;
    my $script=SAS_ODA_Runner::_normalize_local_path_for_python(File::Spec->catfile($Bin,'test_macroparas_gtex.py'),$python);
    my $perl=SAS_ODA_Runner::_normalize_local_path_for_python($^X,$python);
    system {$python} $python,$script,@ARGV,'--runner','perl','--perl',$perl;
    exit($? == -1 ? 1 : $? >> 8);
}
