#!/usr/bin/env perl
use strict; use warnings;
use FindBin qw($Bin);
use Cwd qw(abs_path);
use File::Temp qw(tempdir);
use JSON::PP qw(decode_json);
use Test::More;
die "Use --live\n" unless @ARGV==1 && $ARGV[0] eq '--live';
my $root=abs_path("$Bin/.."); chdir $root or die $!;
my $out=tempdir('SAS_Output_error_recovery_XXXXXX',DIR=>$root,CLEANUP=>0);
my $session='recovery_'.time.'_'.$$;
my $prefix='r'.time.'_'.$$;
local $ENV{SAS_ODA_AUTOLOAD_MACROS}=0; local $ENV{OPEN_RESULT}=0;
sub text {open my $f,'<:raw',$_[0] or return ''; local $/; return <$f>;}
sub submit {
    my ($label,$code)=@_;
    open my $f,'>',"$out/$label.sas" or die $!; print {$f} $code; close $f or die $!;
    my $pid=fork(); die $! unless defined $pid;
    if (!$pid) {open STDOUT,'>',"$out/$label.cli.log" or die $!; open STDERR,'>&STDOUT' or die $!;
        exec $^X,"$root/run_sas_codes_or_files_in_ODA.pl",'--file',"$out/$label.sas",'--persistent',
            '--session-id',$session,'--run-timeout-seconds',120,'--output-prefix',"$out/$label"; die $!;}
    waitpid($pid,0); return $?>>8;
}
isnt(submit('error',"data ${prefix}a; x=6; run; proc sql; select ${prefix}absent from ${prefix}a; quit;"),0,'intentional SAS semantic error returns nonzero');
my $failed=decode_json(text("$out/error/output.run.status.json"));
ok($failed->{complete} && !$failed->{success} && $failed->{state} eq 'failed','failed job status is terminal and unsuccessful');
is(submit('recovered',"data _null_; set ${prefix}a; answer=x*7; if answer=42 then put 'SAS_RECOVERY_OK'; else put 'ERROR: recovery assertion'; run; proc datasets library=work nolist; delete ${prefix}:; quit;"),0,
    'valid code succeeds in the same persistent session after the SAS error');
like(text("$out/recovered/output.html.info.txt"),qr/^SAS_RECOVERY_OK[ \t]*\r?$/m,'recovered submission executes using WORK data retained from the failed job');
my $completed=decode_json(text("$out/recovered/output.run.status.json"));
ok($completed->{complete} && $completed->{success} && $completed->{state} eq 'completed','recovered job status is completed and successful');
is($completed->{session_id},$failed->{session_id},'recovery reused the same session identity');
diag("Live artifacts: $out"); done_testing();
