#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);
use Digest::SHA qw(sha256_hex);
use Test::More;
open my $fh,'<',"$Bin/run_live_new_examples_30.pl" or die $!;
my $source=do {local $/; <$fh>}; close $fh;
my ($fn)=$source =~ /^(sub example_fingerprint \{.*?^\})/ms;
eval $fn; die $@ if $@;
is(example_fingerprint("data e191; x=7; run; MCP30_OK_191"),example_fingerprint("data e999; x=7; run; MCP30_OK_999"),'renaming generated IDs does not create a new example');
is(example_fingerprint("data e191;\n x=7; run;"),example_fingerprint("data e999; x=7; run;"),'whitespace cannot bypass duplicate checks');
isnt(example_fingerprint('data e191; x=7; run;'),example_fingerprint('data e191; x=8; run;'),'semantic input differences retained');
isnt(example_fingerprint(q{%let x=%nrstr(%literal());}),example_fingerprint(q{%let x=%bquote(%nrstr(%literal()));}),'new nested context differs from original NRSTR case');
is(example_fingerprint('MCP30_ASSERT_191'),example_fingerprint('MCP30_ASSERT_290'),'assertion marker IDs normalized');
done_testing();
