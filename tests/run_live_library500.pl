#!/usr/bin/env perl
use strict; use warnings;
use FindBin qw($Bin);
use lib "$Bin/../MCPDeps";
use SAS_Evaluation_Log;
use SAS_Evaluation_Corpus;
use Cwd qw(abs_path);
use File::Temp qw(tempdir);
use JSON::PP;
use Getopt::Long qw(GetOptions);
use Time::HiRes qw(time);
my ($live,$only,$batch,$round)=(0,'',100,1);
GetOptions('live'=>\$live,'only=s'=>\$only,'batch-size=i'=>\$batch,'round=i'=>\$round) or die 'Invalid options';
die "Usage: $0 --live [--round 1|2|3|4|5|6|7|8] [--only L441,L442] [--batch-size 100]\n" unless $live;
die 'Batch size must be 1..100' unless $batch>=1 && $batch<=100;
die 'Round must be 1 through 8' unless $round>=1 && $round<=8;
my $root=abs_path("$Bin/.."); chdir $root or die $!;
sub read_text {open my $f,'<:raw',$_[0] or return ''; local $/; return <$f>;}
sub required_text {my $text=read_text($_[0]); die "Missing or empty required input $_[0]\n" unless length $text; return $text;}
sub save {open my $f,'>:raw',$_[0] or die $!; print {$f} $_[1]; close $f or die $!;}
my $directory=$round==1?'library500':"library500_round$round";
my $marker=$round==1?'LIB500_PASS':"ROUND${round}_PASS";
my $manifest=JSON::PP::decode_json(required_text("$Bin/$directory/manifest.json"));
my @cases=@{SAS_Evaluation_Corpus::select_cases($manifest,$only)};
my %programs=map {$_->{id}=>SAS_Evaluation_Corpus::checked_source($_,required_text("$Bin/$directory/$_->{file}"))} @cases;
my $out=tempdir('SAS_Output_library500_live_XXXXXX',DIR=>$root,CLEANUP=>0);
my $session='library500_'.int(time).'_'.$$;
local $ENV{SAS_ODA_AUTOLOAD_MACROS}=0;
local $ENV{OPEN_RESULT}=0;
$|=1;
print "Artifacts: $out\n";
my (@results,@batches);
while (@cases) {
    my @group;
    if ($cases[0]{expected_failure}) {push @group,shift @cases;}
    else {push @group,shift @cases while @cases && !$cases[0]{expected_failure} && @group<$batch;}
    my $label=$group[0]{id}.'_'.$group[-1]{id};
    my $code="options notes;\n".join("\n",map {$programs{$_->{id}}} @group);
    save("$out/$label.sas",$code);
    my $start=time;
    my $pid=fork(); die $! unless defined $pid;
    if (!$pid) {
        open STDOUT,'>',"$out/$label.cli.log" or die $!;
        open STDERR,'>&STDOUT' or die $!;
        exec $^X,"$root/run_sas_codes_or_files_in_ODA.pl",'--file',"$out/$label.sas",
            '--persistent','--session-id',$session,'--run-timeout-seconds','180',
            '--output-prefix',"$out/$label";
        die "Cannot execute CLI: $!";
    }
    waitpid($pid,0); my $status=$?; my $rc=$status & 127 ? 128+($status&127) : $status>>8;
    my $report=read_text("$out/$label/output.html.info.txt");
    my $terminal=eval {JSON::PP::decode_json(required_text("$out/$label/output.run.status.json"))};
    my $evaluation=SAS_Evaluation_Log::evaluate(report=>$report,marker=>$marker,
        expected=>[map {$_->{id}} @group],exit_code=>$rc,
        expected_failure=>$group[0]{expected_failure}//0,diagnostic=>$group[0]{diagnostic},
        status=>$terminal,require_status=>1);
    for my $case (@group) {
        push @results,{id=>$case->{id},family=>$case->{family},
            pass=>$evaluation->{passes}{$case->{id}}?JSON::PP::true:JSON::PP::false,
            marker_count=>$evaluation->{counts}{$case->{id}}//0,batch=>$label,
            expected_failure=>$case->{expected_failure}?JSON::PP::true:JSON::PP::false,
            diagnostic_match=>$evaluation->{diagnostic_match},body_sha256=>$case->{body_sha256},
            contract_sha256=>SAS_Evaluation_Corpus::contract_fingerprint($case),
            status_valid=>$evaluation->{status_valid},infrastructure_failure=>$evaluation->{infrastructure_failure}};
    }
    push @batches,{label=>$label,exit_code=>$rc,errors=>$evaluation->{errors},
        unexpected_markers=>$evaluation->{unexpected},has_runtime_log=>$evaluation->{has_runtime_log},seconds=>time-$start};
    $batches[-1]{terminal_status}=$terminal;
    my $count=grep {$_->{pass}} @results;
    print "$label exit=$rc, cumulative $count/".scalar(@results)." passed\n";
    save("$out/results.json",JSON::PP->new->canonical->pretty->encode({selected=>scalar @results,
        results=>\@results,batches=>\@batches,session=>$session,round=>$round}));
}
my $failed=grep {!$_->{pass}} @results;
print "Final: ".(@results-$failed).'/'.scalar(@results)." passed; $failed failed\n";
exit($failed?1:0);
