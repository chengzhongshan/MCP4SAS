#!/usr/bin/env perl
use strict; use warnings;
use FindBin qw($Bin); use lib "$Bin/../MCPDeps";
use SAS_Evaluation_Corpus; use Cwd qw(abs_path); use File::Temp qw(tempdir);
use JSON::PP qw(encode_json decode_json); use Test::More;
my $root=abs_path("$Bin/..");
sub text {open my $f,'<:raw',$_[0] or die $!; local $/; return <$f>;}
sub save {open my $f,'>:raw',$_[0] or die $!; print {$f} $_[1]; close $f or die $!;}
my $manifest=decode_json(text("$Bin/library500_round8/manifest.json"));
my @cases=@{$manifest->{cases}}[0,1];
my $label="$cases[0]{id}_$cases[1]{id}";
sub collect {
    my ($kind)=@_;
    my $run=tempdir('SAS_Output_library500_live_audit_XXXXXX',DIR=>$root,CLEANUP=>1);
    mkdir "$run/$label" or die $!;
    # Synthetic logs exercise the collector only; these are not live SAS evidence.
    my $source="options notes;\n".join("\n",map {text("$Bin/library500_round8/$_->{file}")} @cases);
    $source.='/* changed submission */' if $kind eq 'source';
    save("$run/$label.sas",$source);
    save("$run/$label/output.html.info.txt","=== SAS Log ===\n".join('',map {"ROUND8_PASS=$_->{id}\n"} @cases)."=== Output ===\n");
    save("$run/$label/output.run.status.json",encode_json({complete=>1,success=>1,state=>'completed'}));
    my @results=map {{id=>$_->{id},batch=>$label,body_sha256=>$_->{body_sha256},pass=>JSON::PP::true,
        contract_sha256=>SAS_Evaluation_Corpus::contract_fingerprint($_)}} @cases;
    $results[0]{contract_sha256}='0'x64 if $kind eq 'contract' || $kind eq 'stale';
    delete $results[0]{contract_sha256} if $kind eq 'missing';
    save("$run/results.json",encode_json({round=>8,selected=>2,results=>\@results,batches=>[{label=>$label,exit_code=>0}]}));
    my $pid=fork(); die $! unless defined $pid;
    if (!$pid) {
        open STDOUT,'>',"$run/collector.log" or die $!; open STDERR,'>&STDOUT' or die $!;
        exec $^X,"$root/tools/collect_library_evaluation_results.pl",'--round',8,'--run',$run,'--output',"$run/audit.json",($kind eq 'stale'?'--skip-stale':());
        die $!;
    }
    waitpid($pid,0);
    return ($?>>8,-f "$run/audit.json"?decode_json(text("$run/audit.json")):undef,text("$run/collector.log"));
}
my ($rc,$audit,$log)=collect('valid');
is($rc,1,'partial synthetic evidence is not complete 500-case success');
is($audit->{verified},2,'two valid same-batch records are independently accounted for');
is(scalar(grep {$_->{contract_verified}} @{$audit->{results}}),2,'both contracts verified');
for my $probe (['contract',qr/Evaluation contract mismatch/],['missing',qr/Missing evaluation contract/],['source',qr/Submitted source mismatch/]) {
    ($rc,$audit,$log)=collect($probe->[0]);
    isnt($rc,0,"$probe->[0] probe fails closed");
    ok(!defined($audit),"$probe->[0] probe cannot write verified evidence");
    like($log,$probe->[1],"$probe->[0] probe reports the precise integrity failure");
}
($rc,$audit,$log)=collect('stale');
is($rc,1,'explicit stale exclusion cannot make a partial corpus complete');
is($audit->{verified},0,'a batch with a changed contract contributes no passing evidence');
is(scalar @{$audit->{stale_attempts}},2,'entire affected batch is preserved as excluded evidence');
is(scalar(grep {$_->{pass}} @{$audit->{results}}),0,'no stale case is promoted to pass');
done_testing();
