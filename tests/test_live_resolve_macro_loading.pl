#!/usr/bin/env perl
use strict; use warnings;
use FindBin qw($Bin);
use Cwd qw(abs_path);
use File::Temp qw(tempdir);
use Test::More;
use Getopt::Long qw(GetOptionsFromArray);
my ($live,$missing,$mode)=(0,0,'resolve');
GetOptionsFromArray(\@ARGV,'live'=>\$live,'expect-missing'=>\$missing,'mode=s'=>\$mode) or die 'Invalid options';
die "Usage: $0 --live [--mode resolve|unquote] [--expect-missing]\n" unless $live && !@ARGV;
die 'Mode must be resolve or unquote' unless $mode eq 'resolve' || $mode eq 'unquote';
my $root=abs_path("$Bin/.."); chdir $root or die $!;
my $out=tempdir("SAS_Output_${mode}_live_XXXXXX",DIR=>$root,CLEANUP=>0);
my $name='rsv'.time.'_'.$$;
my $session='resolve_'.$name;
local $ENV{SAS_ODA_AUTOLOAD_MACROS}=0;
local $ENV{OPEN_RESULT}=0;
sub read_text {open my $f,'<:raw',$_[0] or return ''; local $/; return <$f>;}
sub cli {
    my ($label,@args)=@_;
    my $pid=fork(); die $! unless defined $pid;
    if (!$pid) {
        open STDOUT,'>',"$out/$label.cli.log" or die $!; open STDERR,'>&STDOUT' or die $!;
        exec $^X,"$root/run_sas_codes_or_files_in_ODA.pl",@args,
            '--persistent','--session-id',$session,'--run-timeout-seconds',120,'--output-prefix',"$out/$label";
        die $!;
    }
    waitpid($pid,0); return $?>>8;
}
sub submit {
    my ($label,$source)=@_;
    open my $f,'>',"$out/$label.sas" or die $!; print {$f} $source; close $f or die $!;
    return cli($label,'--file',"$out/$label.sas");
}
my $home=q{%let rsvhome=%sysfunc(pathname(HOME));};
is(submit('precheck',"$home\ndata _null_; if fileexist(\"&rsvhome/Macros/$name.sas\") then put 'ERROR: fixture collision'; run;"),0,
    'unique remote macro filename is unused');
BAIL_OUT("Precheck failed; inspect $out") if Test::More->builder->is_passing==0;
my $setup="$home\nfilename rsvsrc \"&rsvhome/Macros/$name.sas\"; data _null_; file rsvsrc; put '%macro $name();42%mend;'; run; filename rsvsrc clear;";
is(submit('setup',$setup),0,'create only the uniquely named owned remote macro source');
my $expression=$mode eq 'resolve'?"RESOLVE(strip('%$name()'))":"\"%UNQUOTE(%NRSTR(%$name()))\"";
my $rc=submit('resolve',"data _null_; actual=input($expression,best32.); if actual=42 then put 'RESOLVE_LOADING_OK'; else put 'ERROR: RESOLVE_LOADING_ASSERT'; run;");
my $log=read_text("$out/resolve/output.html.info.txt");
if ($missing) {
    isnt($rc,0,"baseline fails without a discoverable $mode dependency");
    unlike($log,qr/^RESOLVE_LOADING_OK[ \t]*\r?$/m,'baseline did not execute the macro body');
} else {
    is($rc,0,"$mode invokes remote macro via targeted loading");
    like($log,qr/^RESOLVE_LOADING_OK[ \t]*\r?$/m,'computed return value is 42');
    like($log,qr/^MCP4SAS_TARGETED_MACRO:\s+\Q$name\E\s+EXACT\b/m,'targeted loader included the owned source');
}
is(cli('cleanup','--delete-file',"~/Macros/$name.sas"),0,'delete and verify only the owned macro fixture');
diag("Live artifacts: $out");
done_testing();
