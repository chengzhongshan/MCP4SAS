#!/usr/bin/env perl
use strict; use warnings;
use FindBin qw($Bin); use Cwd qw(abs_path); use File::Temp qw(tempdir); use Getopt::Long qw(GetOptions); use Test::More;
my ($live,$missing,$style)=(0,0,'inc'); GetOptions('live'=>\$live,'expect-missing'=>\$missing,'style=s'=>\$style) or die 'Invalid options';
die 'Use --live [--style inc|dosubl|execute] [--expect-missing]' unless $live;
die 'Invalid include style' unless $style=~/^(?:inc|dosubl|execute)$/;
my $root=abs_path("$Bin/.."); chdir $root or die $!;
my $out=tempdir('SAS_Output_inc_alias_XXXXXX',DIR=>$root,CLEANUP=>0);
my $tag='ial'.time.'_'.$$; my $file="$tag.sas"; my $session='inc_'.$tag;
local $ENV{SAS_ODA_AUTOLOAD_MACROS}=0; local $ENV{OPEN_RESULT}=0;
local $ENV{INCLUDE_PREFLIGHT_ENABLED}=0; local $ENV{WRAP_FILE_INCLUDE_DEBUG}=0;
sub read_text {open my $f,'<:raw',$_[0] or return ''; local $/; return <$f>;}
sub save {open my $f,'>',$_[0] or die $!; print {$f} $_[1]; close $f or die $!;}
sub cli {
    my ($label,@args)=@_; my $pid=fork(); die $! unless defined $pid;
    if (!$pid) {open STDOUT,'>',"$out/$label.cli.log" or die $!; open STDERR,'>&STDOUT' or die $!;
        exec $^X,"$root/run_sas_codes_or_files_in_ODA.pl",@args,'--persistent','--session-id',$session,
            '--run-timeout-seconds',120,'--output-prefix',"$out/$label"; die $!;}
    waitpid($pid,0); return $?>>8;
}
save("$out/precheck.sas","%let ihome=%sysfunc(pathname(HOME)); data _null_; if fileexist(\"&ihome/$file\") then put 'ERROR: owned fixture collision'; run;");
is(cli('precheck','--file',"$out/precheck.sas"),0,'unique remote upload filename is unused');
BAIL_OUT("Fixture collision; inspect $out") unless Test::More->builder->is_passing;
save("$out/$file","data ${tag}a; value=42; run;\n");
(my $path="$out/$file")=~s/'/''/g;
my $statement="%include '$path';"; $statement=~s/"/""/g;
my $include=$style eq 'inc'?"%inc '$path';":$style eq 'dosubl'?"data _null_; rc=dosubl(\"$statement\"); run;":"data _null_; call execute(\"$statement\"); run;";
save("$out/alias.sas","$include data _null_; set ${tag}a; if value=42 then put 'INCLUDE_ALIAS_OK'; else put 'ERROR: include alias assertion'; run; proc datasets library=work nolist; delete ${tag}:; quit;");
my $rc=cli('alias','--file',"$out/alias.sas"); my $log=read_text("$out/alias/output.html.info.txt");
if ($missing) {isnt($rc,0,"baseline cannot execute unuploaded local include ($style)"); unlike($log,qr/^INCLUDE_ALIAS_OK[ \t]*\r?$/m,'baseline did not execute payload');}
else {
    is($rc,0,"local include uploads and executes ($style)");
    like($log,qr/^INCLUDE_ALIAS_OK[ \t]*\r?$/m,'included local payload actually ran');
    like($log,qr/Uploaded %include:/,'runner reports discovered include dependency upload');
    unlike($log,qr/targeted remote macro loader for:\s*inc\b/i,'INC is not treated as an external macro');
}
is(cli('cleanup','--delete-file',"~/$file"),0,'delete/verify only the unique uploaded payload, or confirm it is absent');
diag("Live artifacts: $out"); done_testing();
