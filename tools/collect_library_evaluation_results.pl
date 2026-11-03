#!/usr/bin/env perl
use strict; use warnings;
use FindBin qw($Bin); use lib "$Bin/../MCPDeps";
use SAS_Evaluation_Log; use Getopt::Long qw(GetOptions); use Cwd qw(abs_path);
use SAS_Evaluation_Corpus;
use File::Basename qw(dirname basename); use JSON::PP;
my ($round,$output,@runs,$skip_stale);
GetOptions('round=i'=>\$round,'run=s@'=>\@runs,'output=s'=>\$output,'skip-stale'=>\$skip_stale) or die 'Invalid options';
die 'Use --round N --run RUN_DIR [--run RUN_DIR ...] --output FILE' unless $round && @runs && $output;
my $root=abs_path("$Bin/.."); my $directory=$round==1?'library500':$round==9?'macro_open_code50':"library500_round$round";
sub read_text {open my $f,'<:raw',$_[0] or die "$_[0]: $!"; local $/; return <$f>;}
my $manifest=decode_json(read_text("$root/tests/$directory/manifest.json"));
my $validated=SAS_Evaluation_Corpus::select_cases($manifest,'');
my %programs=map {$_->{id}=>SAS_Evaluation_Corpus::checked_source($_,read_text("$root/tests/$directory/$_->{file}"))} @$validated;
my %cases=map {$_->{id}=>$_} @{$manifest->{cases}};
my (%chosen,%attempts,@run_audit,@recorded_failures,@stale_attempts);
my $marker=$round==1?'LIB500_PASS':"ROUND${round}_PASS";
for my $path (@runs) {
    my $run=abs_path($path) or die "Missing run $path";
    die 'Run outside evaluation workspace' unless dirname($run) eq $root && basename($run)=~/^SAS_Output_library500_live_[A-Za-z0-9_]+$/;
    my $data=decode_json(read_text("$run/results.json")); die 'Wrong round' unless $data->{round}==$round;
    my %batches=map {$_->{label}=>$_} @{$data->{batches}};
    my (%checked_submissions,%terminal_states,%evaluations,%groups);
    push @{$groups{$_->{batch}}},$_ for @{$data->{results}};
    my %stale_batches;
    if ($skip_stale) {
        for my $result (@{$data->{results}}) {
            my $case=$cases{$result->{id}} or die "Unknown ID $result->{id}";
            $stale_batches{$result->{batch}}=1 if ($result->{body_sha256}//'') ne $case->{body_sha256}
                || (defined($result->{contract_sha256}) && $result->{contract_sha256} ne SAS_Evaluation_Corpus::contract_fingerprint($case));
        }
    }
    my $verified=0;
    for my $result (@{$data->{results}}) {
        my $case=$cases{$result->{id}} or die "Unknown ID $result->{id}";
        my $label=$result->{batch}; die 'Invalid batch label' unless $label=~/^[A-Z]\d{3,4}_[A-Z]\d{3,4}$/;
        if ($stale_batches{$label}) {
            push @stale_attempts,{id=>$case->{id},source_run=>basename($run),batch=>$label,
                recorded_exit_code=>$batches{$label}{exit_code},recorded_terminal_state=>$batches{$label}{terminal_status}{state},
                recorded_terminal_message=>$batches{$label}{terminal_status}{message},
                recorded_pass=>$result->{pass},recorded_body_sha256=>$result->{body_sha256},current_body_sha256=>$case->{body_sha256},
                recorded_contract_sha256=>$result->{contract_sha256},current_contract_sha256=>SAS_Evaluation_Corpus::contract_fingerprint($case),
                reason=>'Batch contains changed executable source or evaluation contract; excluded, not counted as passing evidence'};
            next;
        }
        die "Body hash mismatch $case->{id}" unless ($result->{body_sha256}//'') eq $case->{body_sha256};
        my $contract_verified=SAS_Evaluation_Corpus::checked_contract($case,$result->{contract_sha256});
        die "Missing evaluation contract $case->{id}" if $round>=8 && !$contract_verified;
        my $batch=$batches{$label} or die 'Missing batch';
        my @group=@{$groups{$label}};
        unless ($checked_submissions{$label}++) {
            my $submitted=read_text("$run/$label.sas");
            my $header=$round==9?"options notes merror serror;\n":"options notes;\n";
            my $expected=$header.join("\n",map {$programs{$_->{id}}//die "Unknown submitted ID $_->{id}"} @group);
            s/\r\n?/\n/g for ($submitted,$expected);
            die "Submitted source mismatch $label" unless $submitted eq $expected;
        }
        my $status=$terminal_states{$label}//=decode_json(read_text("$run/$label/output.run.status.json"));
        my $evaluation_key=join "\0",$label,$case->{expected_failure}?1:0,$case->{diagnostic}//'',$case->{warning_pattern}//'',$case->{policy_failure}?1:0;
        my $eval=$evaluations{$evaluation_key}//=SAS_Evaluation_Log::evaluate(report=>read_text("$run/$label/output.html.info.txt"),marker=>$marker,
            expected=>[map {$_->{id}} @group],exit_code=>$batch->{exit_code},expected_failure=>$case->{expected_failure}//0,
            diagnostic=>$case->{diagnostic},warning_pattern=>$case->{warning_pattern},policy_failure=>$case->{policy_failure},status=>$status,require_status=>1);
        my $attempt={id=>$case->{id},source_run=>basename($run),batch=>$label,body_sha256=>$case->{body_sha256},
            pass=>$eval->{passes}{$case->{id}}?JSON::PP::true:JSON::PP::false,recorded_pass=>$result->{pass},expected_failure=>$case->{expected_failure}?JSON::PP::true:JSON::PP::false,
            contract_sha256=>$result->{contract_sha256},contract_verified=>$contract_verified?JSON::PP::true:JSON::PP::false,
            exit_code=>$batch->{exit_code},marker_count=>$eval->{counts}{$case->{id}}//0,diagnostic_match=>$eval->{diagnostic_match},
            warning_match=>$eval->{warning_match},
            policy_failure=>$case->{policy_failure}?JSON::PP::true:JSON::PP::false,
            status_valid=>$eval->{status_valid},infrastructure_failure=>$eval->{infrastructure_failure},
            terminal_state=>$status->{state},terminal_success=>$status->{success},terminal_complete=>$status->{complete},
            failure_class=>$status->{failure_class}//'',family=>$case->{family}};
        push @{$attempts{$case->{id}}},$attempt;
        push @recorded_failures,$attempt unless $result->{pass};
        if ($attempt->{pass}) {$chosen{$case->{id}}=$attempt; ++$verified;}
    }
    push @run_audit,{source_run=>basename($run),selected=>$data->{selected},verified=>$verified,
        recorded_passed=>scalar(grep {$_->{pass}} @{$data->{results}})};
}
my @results=map {$chosen{$_->{id}}//{id=>$_->{id},pass=>JSON::PP::false,body_sha256=>$_->{body_sha256}}} @{$manifest->{cases}};
my $verified=grep {$_->{pass}} @results;
my @failures=map {grep {!$_->{pass}} @{$attempts{$_}||[]}} sort keys %attempts;
open my $f,'>', $output or die "$output: $!";
print {$f} JSON::PP->new->canonical->pretty->encode({schema=>2,round=>$round,selected=>scalar @results,verified=>$verified,
    results=>\@results,run_evidence=>\@run_audit,failed_attempts=>\@failures,
    recorded_failures=>\@recorded_failures,stale_attempts=>\@stale_attempts}); close $f or die $!;
print "Verified $verified/".scalar(@results)." distinct cases across ".scalar(@runs)." runs; preserved ".scalar(@failures)." unsuccessful attempts\n";
exit($verified==@results?0:1);
