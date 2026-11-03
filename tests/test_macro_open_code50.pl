#!/usr/bin/env perl
use strict; use warnings; use FindBin qw($Bin); use lib "$Bin/../MCPDeps";
use SAS_Source_Analysis; use SAS_Evaluation_Corpus; use JSON::PP qw(decode_json); use Test::More;
sub text {open my $f,'<:raw',$_[0] or die $!; local $/; return <$f>;}
my $dir="$Bin/macro_open_code50"; my $m=decode_json(text("$dir/manifest.json"));
my @cases=@{SAS_Evaluation_Corpus::select_cases($m,'')}; is(scalar @cases,50,'50 distinct macro boundary examples');
my %fingerprints;
for my $prior ('library500',map {"library500_round$_"} 2..8) {
    my $p=decode_json(text("$Bin/$prior/manifest.json"));
    $fingerprints{SAS_Evaluation_Corpus::behavior_fingerprint($_,text("$Bin/$prior/$_->{file}"))}=1 for @{$p->{cases}};
}
my ($negative,$warning,$structural,$clean)=(0,0,0,0);
for my $case (@cases) {subtest "$case->{id} $case->{family}" => sub {
    my $source=text("$dir/$case->{file}");
    ok(eval {SAS_Evaluation_Corpus::checked_source($case,$source);1},'actual executable body matches manifest');
    ok(!$fingerprints{SAS_Evaluation_Corpus::behavior_fingerprint($case,$source)}++,'new normalized body against all previous 4000 cases');
    ok(length($case->{evidence}{book_title}//''),'actual book provenance recorded');
    is_deeply(SAS_Source_Analysis::analyze_source($source)->{findings},[],'balanced lexical source');
    my $lint=SAS_Source_Analysis::open_code_macro_issues($source);
    my %types=map {$_->{type}=>1} @$lint;
    if (@{$case->{expected_lint}}) {
        ++$structural; ok($types{$_},"identified $_") for @{$case->{expected_lint}};
    } elsif (!$case->{expected_failure}) {++$clean; is_deeply($lint,[],'valid open code or macro wrapper is not blocked');}
    else {pass('runtime-dependent expression/parameter failure does not require a speculative static blocker');}
    ++$negative if $case->{expected_failure}; ++$warning if length($case->{warning_pattern}//'');
};}
is($negative,20,'20 intended fatal SAS cases'); is($warning,5,'five successful jobs must expose actual macro warnings');
is($structural,14,'14 structural open-code problems protected by preflight'); is($clean,30,'30 positive/warning cases are not blocked');
done_testing();
