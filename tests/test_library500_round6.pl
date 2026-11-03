#!/usr/bin/env perl
use strict; use warnings;
use FindBin qw($Bin); use lib "$Bin/../MCPDeps";
use SAS_Source_Analysis; use Digest::SHA qw(sha256_hex); use JSON::PP qw(decode_json); use Test::More;
sub read_text {open my $f,'<:raw',$_[0] or die "$_[0]: $!"; local $/; return <$f>;}
my $dir="$Bin/library500_round6"; my $manifest=decode_json(read_text("$dir/manifest.json"));
is($manifest->{count},500,'500 sixth-round scenarios'); is(scalar @{$manifest->{cases}},500,'500 manifest entries');
my %old; for my $prior ('library500',map {"library500_round$_"} 2..5) {my $m=decode_json(read_text("$Bin/$prior/manifest.json")); $old{$_->{body_sha256}}=1 for @{$m->{cases}};}
my (%seen,%families,$negative);
for my $case (@{$manifest->{cases}}) {
    subtest "$case->{id} $case->{family} N=$case->{input_n}" => sub {
        my $source=read_text("$dir/$case->{file}");
        (my $canonical=$source)=~s{\A/\*[^\n]*\*/\n}{}; $canonical=~s/h\d{4}/hCASE/ig;
        is(sha256_hex($canonical),$case->{body_sha256},'body matches recorded fingerprint');
        ok(!$seen{$case->{body_sha256}}++ && !$old{$case->{body_sha256}},'distinct executable body');
        is_deeply(SAS_Source_Analysis::analyze_source($source)->{findings},[],'valid lexical structure');
        is_deeply(SAS_Source_Analysis::include_targets($source),[],'no external include path invented');
        if ($case->{expected_failure}) {++$negative; unlike($source,qr/ROUND6_PASS=/,'negative case has no positive marker'); ok(length($case->{diagnostic}//''),'expected diagnostic specified');}
        else {like($source,qr/ROUND6_PASS=\Q$case->{id}\E/,'own runtime marker'); ok(defined $case->{expected},'independent oracle');}
        like($source,qr/delete \Q$case->{tables_prefix}\E:/,'only own WORK prefix cleanup'); $families{$case->{family}}++;
    };
}
is(scalar keys %families,50,'50 families'); is_deeply([sort values %families],[(10)x50],'ten scenarios each');
is($negative,50,'450 expected successes and 50 expected errors'); done_testing();
