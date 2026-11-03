#!/usr/bin/env perl
use strict; use warnings; use FindBin qw($Bin); use Cwd qw(abs_path); use File::Temp qw(tempdir); use JSON::PP qw(decode_json); use Test::More;
plan skip_all=>'Use --live to verify the configured CLI preflight (SAS credentials must be available)' unless grep {$_ eq '--live'} @ARGV;
my $root=abs_path("$Bin/.."); chdir $root or die $!;
my $out=tempdir('SAS_Output_macro_preflight_XXXXXX',DIR=>$root,CLEANUP=>0);
sub text {open my $f,'<:raw',$_[0] or die $!; local $/; return <$f>;}
local $ENV{SUBMISSION_PREFLIGHT_ENABLED}=1; local $ENV{SAS_ODA_AUTOLOAD_MACROS}=0; local $ENV{OPEN_RESULT}=0;
for my $entry (qw(run_sas_codes_or_files_in_ODA.pl run_sas_codes_or_script_in_ODA.pl)) {
    for my $id (qw(M4026 M4027 M4034 M4035 M4036)) {
        my $prefix="$out/$entry.$id";
        my $pid=fork(); die $! unless defined $pid;
        if (!$pid) {open STDOUT,'>',"$prefix.cli.log" or die $!; open STDERR,'>&STDOUT' or die $!;
            exec $^X,"$root/$entry",'--file',"$Bin/macro_open_code50/$id.sas",'--output-prefix',$prefix; die $!;}
        waitpid($pid,0); is($?>>8,1,"$entry $id returns failed job exit");
        my $status=decode_json(text("$prefix/output.run.status.json"));
        like($status->{message},qr/Submission preflight.*skipped SAS submit/,"$entry $id prevented remote submission");
        ok($status->{complete} && !$status->{success} && $status->{state} eq 'failed',"$entry $id has complete failed metadata");
    }
}
diag("Preflight artifacts: $out"); done_testing();
