#!/usr/bin/env perl
use strict; use warnings;
use FindBin qw($Bin);
use lib "$Bin/../MCPDeps";
use SAS_Source_Analysis;
use Digest::SHA qw(sha256_hex);
use JSON::PP qw(decode_json);
use Test::More;
sub read_text {open my $f,'<:raw',$_[0] or die "$_[0]: $!"; local $/; return <$f>;}
my $dir="$Bin/library500";
my $manifest=decode_json(read_text("$dir/manifest.json"));
is($manifest->{count},500,'manifest declares 500 runnable cases');
is(scalar @{$manifest->{cases}},500,'manifest contains exactly 500 cases');
my (%seen,%families);
for my $case (@{$manifest->{cases}}) {
    subtest "$case->{id} $case->{family} input $case->{input_index}" => sub {
        my $source=read_text("$dir/$case->{file}");
        (my $canonical=$source)=~s{\A/\*[^\n]*\*/\n}{};
        $canonical=~s/L\d{3}/LCASE/g;
        is(sha256_hex($canonical),$case->{body_sha256},'executable body matches reviewed oracle manifest');
        ok(!$seen{$case->{body_sha256}}++,'not an ID-only duplicate');
        like($case->{evidence}{source_sha256},qr/^[a-f0-9]{64}$/,'original library source fingerprint recorded');
        is_deeply(SAS_Source_Analysis::analyze_source($source)->{findings},[],'valid SAS passes lexical preflight');
        is_deeply(SAS_Source_Analysis::include_targets($source),[],'no invented file dependencies');
        like($source,qr/LIB500_PASS=\Q$case->{id}\E/,'case has its own runtime result marker');
        $families{$case->{family}}++;
    };
}
is(scalar keys %families,50,'50 distinct behavior families');
is_deeply([sort values %families],[(10)x50],'ten distinct inputs per family');
done_testing();
