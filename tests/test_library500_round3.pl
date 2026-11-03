#!/usr/bin/env perl
use strict; use warnings;
use FindBin qw($Bin);
use lib "$Bin/../MCPDeps";
use SAS_Source_Analysis;
use Digest::SHA qw(sha256_hex);
use JSON::PP qw(decode_json);
use Test::More;
sub read_text {open my $f,'<:raw',$_[0] or die "$_[0]: $!"; local $/; return <$f>;}
my $dir="$Bin/library500_round3";
my $manifest=decode_json(read_text("$dir/manifest.json"));
is($manifest->{count},500,'500 third-round evaluations declared');
is(scalar @{$manifest->{cases}},500,'exactly 500 manifest entries');
my %old;
for my $prior ('library500','library500_round2') {
    my $m=decode_json(read_text("$Bin/$prior/manifest.json"));
    $old{$_->{body_sha256}}=1 for @{$m->{cases}};
}
my (%seen,%families);
for my $case (@{$manifest->{cases}}) {
    subtest "$case->{id} $case->{family} N=$case->{input_n}" => sub {
        my $source=read_text("$dir/$case->{file}");
        (my $canonical=$source)=~s{\A/\*[^\n]*\*/\n}{}; $canonical=~s/t\d{4}/tCASE/ig;
        is(sha256_hex($canonical),$case->{body_sha256},'body matches independent manifest');
        ok(!$seen{$case->{body_sha256}}++ && !$old{$case->{body_sha256}},'distinct body fingerprint');
        is_deeply(SAS_Source_Analysis::analyze_source($source)->{findings},[],'valid lexical structure');
        is_deeply(SAS_Source_Analysis::include_targets($source),[],'no external include dependency');
        like($source,qr/ROUND3_PASS=\Q$case->{id}\E/,'own runtime assertion');
        like($source,qr/delete \Q$case->{tables_prefix}\E:/,'only own WORK prefix is cleaned');
        $families{$case->{family}}++;
    };
}
is(scalar keys %families,50,'50 third-round families');
is_deeply([sort values %families],[(10)x50],'ten scenarios per family');
done_testing();
