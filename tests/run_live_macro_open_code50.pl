#!/usr/bin/env perl
use strict; use warnings; use FindBin qw($Bin); use lib "$Bin/../MCPDeps";
use SAS_Evaluation_Log; use SAS_Evaluation_Corpus; use Cwd qw(abs_path);
use File::Temp qw(tempdir); use JSON::PP; use Getopt::Long qw(GetOptions); use Time::HiRes qw(time);
my ($live,$raw,$only)=(0,0,''); GetOptions('live'=>\$live,'raw'=>\$raw,'only=s'=>\$only) or die 'Invalid options';
die "Usage: $0 --live --raw [--only M4026,M4036]\n--raw bypasses static preflight to measure actual SAS diagnostics. Each case uses a fresh isolated SAS connection.\n" unless $live && $raw;
my $root=abs_path("$Bin/.."); chdir $root or die $!;
sub text {open my $f,'<:raw',$_[0] or die "$_[0]: $!"; local $/; return <$f>;}
sub save {open my $f,'>:raw',$_[0] or die $!; print {$f} $_[1]; close $f or die $!;}
my $manifest=decode_json(text("$Bin/macro_open_code50/manifest.json"));
my @cases=@{SAS_Evaluation_Corpus::select_cases($manifest,$only)};
my %programs=map {$_->{id}=>SAS_Evaluation_Corpus::checked_source($_,text("$Bin/macro_open_code50/$_->{file}"))} @cases;
my $out=tempdir('SAS_Output_library500_live_XXXXXX',DIR=>$root,CLEANUP=>0);
local $ENV{SUBMISSION_PREFLIGHT_ENABLED}=0; local $ENV{INCLUDE_PREFLIGHT_ENABLED}=0;
local $ENV{SAS_ODA_AUTOLOAD_MACROS}=0; local $ENV{OPEN_RESULT}=0;
$|=1; print "Artifacts: $out\n";
my (@results,@batches);
for my $case (@cases) {
    my $id=$case->{id}; my $label="${id}_$id"; my $start=time;
    save("$out/$label.sas","options notes merror serror;\n$programs{$id}");
    my $pid=fork(); die $! unless defined $pid;
    if (!$pid) {
        open STDOUT,'>',"$out/$label.cli.log" or die $!; open STDERR,'>&STDOUT' or die $!;
        exec $^X,"$root/run_sas_codes_or_files_in_ODA.pl",'--file',"$out/$label.sas",'--run-timeout-seconds',120,'--output-prefix',"$out/$label";
        die $!;
    }
    waitpid($pid,0); my $status=$?; my $rc=$status&127?128+($status&127):$status>>8;
    my $report=eval {text("$out/$label/output.html.info.txt")} // '';
    my $terminal=eval {decode_json(text("$out/$label/output.run.status.json"))};
    my $e=SAS_Evaluation_Log::evaluate(report=>$report,marker=>'ROUND9_PASS',expected=>[$id],exit_code=>$rc,
        expected_failure=>$case->{expected_failure},policy_failure=>$case->{policy_failure},diagnostic=>$case->{diagnostic},warning_pattern=>$case->{warning_pattern},status=>$terminal,require_status=>1);
    push @results,{id=>$id,family=>$case->{family},pass=>$e->{passes}{$id}?JSON::PP::true:JSON::PP::false,batch=>$label,
        expected_failure=>$case->{expected_failure},policy_failure=>$case->{policy_failure},body_sha256=>$case->{body_sha256},contract_sha256=>SAS_Evaluation_Corpus::contract_fingerprint($case),
        marker_count=>$e->{counts}{$id}//0,diagnostic_match=>$e->{diagnostic_match},warning_match=>$e->{warning_match},
        status_valid=>$e->{status_valid},infrastructure_failure=>$e->{infrastructure_failure}};
    push @batches,{label=>$label,exit_code=>$rc,errors=>$e->{errors},terminal_status=>$terminal,seconds=>time-$start};
    my $passed=grep {$_->{pass}} @results;
    print "$label exit=$rc, cumulative $passed/".scalar(@results)." passed\n";
    save("$out/results.json",JSON::PP->new->canonical->pretty->encode({round=>9,selected=>scalar(@results),results=>\@results,batches=>\@batches,submission_header=>"options notes merror serror;\n",isolated=>JSON::PP::true,raw_preflight_bypass=>JSON::PP::true}));
}
my $failed=grep {!$_->{pass}} @results; print 'Final: '.(@results-$failed).'/'.scalar(@results)." passed; $failed failed\n"; exit($failed?1:0);
