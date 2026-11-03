#!/usr/bin/env perl
use strict; use warnings;
use FindBin qw($Bin); use Cwd qw(abs_path); use File::Temp qw(tempdir); use Test::More;
die "Use --live\n" unless @ARGV==1 && $ARGV[0] eq '--live';
my $root=abs_path("$Bin/.."); chdir $root or die $!;
my $out=tempdir('SAS_Output_builtin_macros_XXXXXX',DIR=>$root,CLEANUP=>0);
local $ENV{SAS_ODA_AUTOLOAD_MACROS}; delete $ENV{SAS_ODA_AUTOLOAD_MACROS};
local $ENV{OPEN_RESULT}=0;
open my $f,'>',"$out/builtin.sas" or die $!;
print {$f} q{%let builtin_test=%qsubstr(%str(abcdef),1,3);
data builtin_bind; builtin_number=42; run;
%let builtin_dsid=%sysfunc(open(builtin_bind,i)); %syscall set(builtin_dsid);
%let builtin_rc=%sysfunc(fetchobs(&builtin_dsid,1));
data _null_; length text $20; text=symget('builtin_test'); if text='abc' and &builtin_number=42 then put 'BUILTIN_MACRO_OK'; else put 'ERROR: builtin macro assertion'; run;
%let builtin_rc=%sysfunc(close(&builtin_dsid));
%symdel builtin_test builtin_dsid builtin_rc builtin_number;
proc datasets library=work nolist; delete builtin_bind; quit;
}; close $f or die $!;
my $pid=fork(); die $! unless defined $pid;
if (!$pid) {open STDOUT,'>',"$out/builtin.cli.log" or die $!; open STDERR,'>&STDOUT' or die $!;
    exec $^X,"$root/run_sas_codes_or_files_in_ODA.pl",'--file',"$out/builtin.sas",'--persistent',
        '--session-id','builtins_'.time.'_'.$$,'--run-timeout-seconds',120,'--output-prefix',"$out/result"; die $!;}
waitpid($pid,0); is($?>>8,0,'builtin-only macro program succeeds with default autoload selection');
sub text {open my $fh,'<:raw',$_[0] or return ''; local $/; return <$fh>;}
like(text("$out/result/output.html.info.txt"),qr/^BUILTIN_MACRO_OK[ \t]*\r?$/m,'builtin result is correct');
like(text("$out/builtin.cli.log"),qr/No explicit %include or non-builtin macro usage detected; skipping global importallmacros_ue bootstrap/,
    'quoting builtins, SYSCALL and SYMDEL do not trigger global macro bootstrap');
unlike(text("$out/result/output.html.info.txt"),qr/Injected targeted remote macro loader/,'no external macro source requested');
diag("Live artifacts: $out"); done_testing();
