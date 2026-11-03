#!/usr/bin/env perl
use strict; use warnings;
use FindBin qw($Bin);
use lib "$Bin/../MCPDeps";
use SAS_Source_Analysis;
use Digest::SHA qw(sha256_hex);
use JSON::PP qw(decode_json);
use Test::More;
sub read_text {open my $f,'<:raw',$_[0] or die "$_[0]: $!"; local $/; return <$f>;}
my $dir="$Bin/library500_round4";
my $manifest=decode_json(read_text("$dir/manifest.json"));
is($manifest->{count},500,'500 fourth-round scenarios declared');
is(scalar @{$manifest->{cases}},500,'exactly 500 manifest entries');
my %old;
for my $prior ('library500','library500_round2','library500_round3') {
    my $m=decode_json(read_text("$Bin/$prior/manifest.json"));
    $old{$_->{body_sha256}}=1 for @{$m->{cases}};
}
my (%seen,%families,$negative);
for my $case (@{$manifest->{cases}}) {
    subtest "$case->{id} $case->{family} N=$case->{input_n}" => sub {
        my $source=read_text("$dir/$case->{file}");
        (my $canonical=$source)=~s{\A/\*[^\n]*\*/\n}{}; $canonical=~s/f\d{4}/fCASE/ig;
        is(sha256_hex($canonical),$case->{body_sha256},'body matches manifest fingerprint');
        ok(!$seen{$case->{body_sha256}}++ && !$old{$case->{body_sha256}},'distinct executable fingerprint');
        is_deeply(SAS_Source_Analysis::analyze_source($source)->{findings},[],'valid lexical structure even for intentional SAS semantic errors');
        is_deeply(SAS_Source_Analysis::include_targets($source),[],'no external include dependency');
        if ($case->{expected_failure}) {
            ++$negative;
            unlike($source,qr/ROUND4_PASS=/,'negative case cannot assert successful calculation');
            ok(length($case->{diagnostic}//''),'specific expected runtime diagnostic required');
        } else {
            like($source,qr/ROUND4_PASS=\Q$case->{id}\E/,'own runtime assertion');
            ok(defined $case->{expected},'independent numerical oracle recorded');
        }
        like($source,qr/delete \Q$case->{tables_prefix}\E:/,'only own WORK prefix is cleaned');
        $families{$case->{family}}++;
    };
}
is(scalar keys %families,50,'50 new families');
is_deeply([sort values %families],[(10)x50],'ten scenarios per family');
is($negative,50,'50 intentional failures and 450 expected-success calculations');
done_testing();
