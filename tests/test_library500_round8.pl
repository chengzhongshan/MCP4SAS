#!/usr/bin/env perl
use strict; use warnings;
use FindBin qw($Bin); use lib "$Bin/../MCPDeps";
use SAS_Source_Analysis; use SAS_Evaluation_Corpus; use JSON::PP qw(decode_json); use Test::More;
sub text {open my $f,'<:raw',$_[0] or die $!; local $/; return <$f>;}
my $dir="$Bin/library500_round8"; my $m=decode_json(text("$dir/manifest.json"));
my $cases=SAS_Evaluation_Corpus::select_cases($m,''); is(scalar @$cases,500,'500 book-derived scenarios');
my (%fingerprints,%families,%books,$negative);
for my $prior ('library500',map {"library500_round$_"} 2..7) {
    my $p=decode_json(text("$Bin/$prior/manifest.json"));
    $fingerprints{SAS_Evaluation_Corpus::behavior_fingerprint($_,text("$Bin/$prior/$_->{file}"))}=1 for @{$p->{cases}};
}
for my $case (@$cases) {
    subtest "$case->{id} $case->{family} N=$case->{input_n}" => sub {
        my $source=text("$dir/$case->{file}");
        ok(eval {SAS_Evaluation_Corpus::checked_source($case,$source);1},'actual body matches manifest');
        ok(!$fingerprints{SAS_Evaluation_Corpus::behavior_fingerprint($case,$source)}++,'different executable fingerprint ignoring case/round labels');
        is($case->{evidence}{source_kind},'book_sample','provenance is the requested book collection');
        ok(length($case->{evidence}{book_title}//''),'book title recorded');
        is_deeply(SAS_Source_Analysis::analyze_source($source)->{findings},[],'balanced lexical source');
        is_deeply(SAS_Source_Analysis::include_targets($source),[],'no external include dependency');
        if ($case->{expected_failure}) {++$negative; unlike($source,qr/ROUND8_PASS=/,'negative case has no success marker');}
        else {like($source,qr/ROUND8_PASS=\Q$case->{id}\E/,'own runtime assertion');}
        $families{$case->{family}}++; $books{$case->{evidence}{book_title}}=1;
    };
}
is(scalar keys %families,50,'50 book-derived families'); is_deeply([sort values %families],[(10)x50],'ten scenarios each');
is($negative,50,'450 positive and 50 intentional SAS errors'); cmp_ok(scalar keys %books,'>=',5,'multiple actual book sources represented');
done_testing();
