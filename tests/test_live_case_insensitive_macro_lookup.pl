#!/usr/bin/env perl
use strict; use warnings;
use FindBin qw($Bin);
use Cwd qw(abs_path);
use File::Temp qw(tempdir);
use Test::More;
die "Use --live\n" unless @ARGV==1 && $ARGV[0] eq '--live';
my $root=abs_path("$Bin/.."); chdir $root or die $!;
my $out=tempdir('SAS_Output_macro_case_XXXXXX',DIR=>$root,CLEANUP=>0);
my $entry=-f "$root/run_sas_codes_or_files_in_ODA.pl"
    ? "$root/run_sas_codes_or_files_in_ODA.pl" : "$root/run_sas_codes_or_files_in_SAS_ODA.pl";
my $tag='ci'.time.'_'.$$;
my $session='macrocase_'.time.'_'.$$;
local $ENV{SAS_ODA_AUTOLOAD_MACROS}=0; local $ENV{OPEN_RESULT}=0;
sub save {open my $fh,'>',$_[0] or die $!; print {$fh} $_[1]; close $fh or die $!;}
sub read_text {open my $fh,'<',$_[0] or return ''; local $/; return <$fh>;}
sub cli {
 my ($label,@args)=@_;
 my $pid=fork(); die $! unless defined $pid;
 if (!$pid) {open STDOUT,'>',"$out/$label.cli.log" or die $!; open STDERR,'>&STDOUT' or die $!;
   exec $^X,$entry,@args,'--persistent','--session-id',$session,
     '--run-timeout-seconds',180,'--output-prefix',"$out/$label"; die $!;}
 waitpid($pid,0); return $?>>8;
}
sub submit {my ($label,$code)=@_; save("$out/$label.sas",$code); return cli($label,'--file',"$out/$label.sas");}
sub log_text {return read_text("$out/$_[0]/output.html.info.txt").read_text("$out/$_[0].cli.log");}
my @fixtures=(
 ["${tag}HoMe.SaS",41], ["Macros/${tag}MiXeD.SAS",43],
 ["${tag}Exact.sas",13], ["${tag}EXACT.sas",17],
 ["${tag}AmBig.sas",19], ["${tag}AMbIG.SAS",29],
 ["${tag}Prio.SaS",23], ["Macros/${tag}PRIO.sas",31],
);
my $setup="%let ci_home=%sysfunc(pathname(HOME));\n";
my $precheck=$setup."data _null_;\n";
for my $fixture (@fixtures) {
 my ($file,$value)=@$fixture; my $macro=$file; $macro=~s{.*/}{}; $macro=~s/\.sas$//i;
 die 'Macro test name too long' if length($macro)>32;
 my $source="%macro $macro; data ci_result; value=$value; run; %put CI_MACRO_BODY_EXECUTED=$value; %mend;";
 $source=~s/'/''/g;
 $precheck.="if fileexist(\"&ci_home/$file\") then put 'ERROR: owned test filename collision';\n";
 $setup.="filename citest \"&ci_home/$file\"; data _null_; file citest; put '$source'; run; filename citest clear;\n";
}
my $checked=submit('precheck',$precheck."run;\n");
is($checked,0,'unique fixture paths do not already exist before opening FILE statements');
BAIL_OUT("Fixture collision; inspect $out/precheck.cli.log") if $checked;
my $rc=submit('setup',$setup);
is($rc,0,'write only uniquely named macro fixtures under remote HOME and Macros');
BAIL_OUT("Inspect $out/setup.cli.log") if $rc;
for my $case (
 ['home_mixed',uc("${tag}HoMe"),41,'CASE_INSENSITIVE'],
 ['macros_mixed',lc("${tag}MiXeD"),43,'CASE_INSENSITIVE'],
 ['exact_preferred',"${tag}Exact",13,'EXACT'],
 ['fallback_exact',"${tag}PRIO",31,'EXACT'],
 ['primary_folded',lc("${tag}Prio"),23,'CASE_INSENSITIVE'],
) {
 my ($label,$macro,$expected,$kind)=@$case;
 is(submit($label,"%$macro; data _null_; set ci_result; if value=$expected then put 'MACRO_CASE_OK'; else put 'ERROR: MACRO_CASE_ASSERT'; run; proc print data=ci_result; run;"),0,"$label executes requested macro");
 my $log=log_text($label);
 like($log,qr/^MACRO_CASE_OK\s*$/m,"$label computed value verified");
 like($log,qr/^MCP4SAS_TARGETED_MACRO:\s+\Q$macro\E\s+\Q$kind\E(?:\s|$)/m,"$label resolution mode reported");
}
my $ambiguous=lc("${tag}AmBig");
isnt(submit('ambiguous',"%$ambiguous;"),0,'ambiguous folded filenames return failure');
my $log=log_text('ambiguous');
like($log,qr/^ERROR: Ambiguous case-insensitive macro filename:/m,'ambiguity reported in primary SAS log');
unlike($log,qr/^CI_MACRO_BODY_EXECUTED=/m,'neither ambiguous source was loaded and executed');
is(cli('cleanup',map {('--delete-file','~/'.$_->[0])} @fixtures),0,'delete and verify only the eight uniquely named remote macro fixtures');
diag("Live artifacts: $out"); done_testing();
