#!/usr/bin/env perl
use strict; use warnings;
use FindBin qw($Bin);
use lib "$Bin/../MCPDeps";
use SAS_Source_Analysis;
use Digest::SHA qw(sha256_hex);
use JSON::PP qw(decode_json);
use Test::More;
sub read_text {open my $f,'<:raw',$_[0] or die "$_[0]: $!"; local $/; return <$f>;}
my $dir="$Bin/library500_round2";
my $manifest=decode_json(read_text("$dir/manifest.json"));
is($manifest->{count},500,'500 new runnable dataset/macro/I-O cases');
is(scalar @{$manifest->{cases}},500,'exactly 500 manifest entries');
my $previous=decode_json(read_text("$Bin/library500/manifest.json"));
my %old=map {$_->{body_sha256}=>1} @{$previous->{cases}};
my (%seen,%families);
for my $case (@{$manifest->{cases}}) {
    subtest "$case->{id} $case->{family} N=$case->{input_n}" => sub {
        my $source=read_text("$dir/$case->{file}");
        (my $canonical=$source)=~s{\A/\*[^\n]*\*/\n}{};
        $canonical=~s/r\d{3,4}/rCASE/ig;
        is(sha256_hex($canonical),$case->{body_sha256},'body matches manifest fingerprint');
        ok(!$seen{$case->{body_sha256}}++ && !$old{$case->{body_sha256}},'unique body, different from previous batch');
        is_deeply(SAS_Source_Analysis::analyze_source($source)->{findings},[],'valid source passes lexical analysis');
        is_deeply(SAS_Source_Analysis::include_targets($source),[],'no external include-file dependency invented');
        like($source,qr/ROUND2_PASS=\Q$case->{id}\E/,'own runtime assertion marker');
        like($source,qr/delete \Q$case->{tables_prefix}\E:/,'cleans only its owned WORK table prefix');
        $families{$case->{family}}++;
    };
}
is(scalar keys %families,50,'50 different operation families');
is_deeply([sort values %families],[(10)x50],'ten input sizes in each family');
done_testing();
