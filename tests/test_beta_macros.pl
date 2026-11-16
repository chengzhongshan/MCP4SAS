#!/usr/bin/env perl
use strict; use warnings; use FindBin qw($Bin); use File::Spec; use Test::More;
my $path=File::Spec->catfile($Bin,'..','examples','sas_macros','scASE_betabino.sas');
open my $fh,'<',$path or die $!;my $text=do{local $/;<$fh>};close $fh;
like($text,qr/tot_var=tot\s*,\s*outdsd=/,'total/output keyword parameters are separated');
unlike($text,qr/&model_vars\b|&modelvars\b/,'no inconsistent predictor macro-variable names');
like($text,qr/b1\*\&model_var\+u/,'NLMIXED uses the caller predictor');
like($text,qr/ParameterEstimates=\&outdsd/,'requested estimate output is honored');
done_testing;
if(grep{$_ eq '--live'}@ARGV){
 require lib;lib->import(File::Spec->catdir($Bin,'..','MCPDeps'));require SAS_ODA_Runner;
 my $python=$ENV{PIPELINE_PYTHON_BIN}||'python3';
 my $script=SAS_ODA_Runner::_normalize_local_path_for_python(File::Spec->catfile($Bin,'test_beta_macros.py'),$python);
 my $perl=SAS_ODA_Runner::_normalize_local_path_for_python($^X,$python);
 system{$python}$python,$script,@ARGV,'--runner','perl','--perl',$perl;
 exit($? == -1 ? 1 : $? >> 8);
}
