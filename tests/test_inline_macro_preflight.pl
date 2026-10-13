#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../MCPDeps";
use SAS_Source_Analysis;
use Test::More;
for my $entry (qw(run_sas_codes_or_files_in_ODA.pl run_sas_codes_or_script_in_ODA.pl)) {
    open my $fh, '<', "$Bin/../$entry" or die $!;
    my $source = do { local $/; <$fh> };
    close $fh;
    for my $name (qw(_blank_preserving_newlines sanitize_sas_text_for_macro_lint scan_sas_text_for_open_code_macro_control)) {
        my ($function) = $source =~ /^(sub \Q$name\E \{.*?^\})/ms;
        die "Missing $name" unless $function;
        no warnings 'redefine';
        eval $function; die $@ if $@;
    }
    for my $code (
        "options mprint; %macro demo;\ndata x; n=1; run;\n%mend;\n%demo;",
        '%macro first; %return; %mend; %macro second; %goto done; %done: %mend;',
        '%macro outer; %macro inner; %mend; %mend;',
        "data x; text='%macro fake; %mend; %goto nope;'; run; /* %macro ignored */",
    ) {
        is_deeply(scan_sas_text_for_open_code_macro_control($code)->{findings}, [], "$entry accepts valid inline/quoted macros");
    }
    my $finding = scan_sas_text_for_open_code_macro_control("options notes;\n%macro unclosed;")->{findings};
    is($finding->[0]{type}, 'unclosed_macro_definition', "$entry retains missing MEND detection");
    $finding = scan_sas_text_for_open_code_macro_control("options notes; %mend;")->{findings};
    is($finding->[0]{type}, 'open_code_mend', "$entry retains stray MEND detection");
    $finding = scan_sas_text_for_open_code_macro_control("data x; run;\noptions notes; %goto nowhere;")->{findings};
    is($finding->[0]{type}, 'open_code_macro_control', "$entry detects control after a semicolon");
    is($finding->[0]{line}, 2, "$entry preserves source line numbers");
}
done_testing();
