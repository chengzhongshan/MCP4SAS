#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../MCPDeps";
use SAS_Source_Analysis;
use Test::More;
for my $entry (qw(run_sas_codes_or_files_in_ODA.pl run_sas_codes_or_script_in_ODA.pl)) {
    open my $fh, '<', "$Bin/../$entry" or die $!;
    my $source=do {local $/; <$fh>}; close $fh;
    for my $name (qw(_blank_preserving_newlines sanitize_sas_text_for_macro_lint scan_sas_text_for_open_code_macro_control _count_newlines scan_sas_text_for_macro_invocation_spans scan_sas_text_for_unclosed_macro_invocations suppress_balanced_macro_invocation_false_positives scan_sas_text_for_unbalanced_constructs scan_sas_text_for_inline_data_step_cards scan_sas_text_for_unsafe_put_semicolons scan_sas_text_for_common_macro_typos)) {
        my ($function)=$source =~ /^(sub \Q$name\E \{.*?^\})/ms;
        die "Missing $name" unless $function;
        no warnings 'redefine'; eval $function; die $@ if $@;
    }
    for my $code (
        "data x; input surname \$; datalines;\nO'Brien\n;\nrun;",
        "data x; input text \$; cards;\n/*raw\n;\nrun;",
        "data x; input text \$; datalines4;\n*/raw\n%macro not_code\nsemicolon;raw\n;;;;\nrun;",
        "data x; input text \$; cards4;\n'unbalanced\n;;;;\nrun;",
    ) {
        is_deeply(scan_sas_text_for_unbalanced_constructs($code)->{findings}, [], "$entry accepts raw inline special characters");
        my $masked=SAS_Source_Analysis::mask_inline_data($code);
        is(length($masked), length($code), 'mask preserves offsets');
        is(($masked =~ tr/\n//), ($code =~ tr/\n//), 'mask preserves line numbers');
    }
    my $bad="data x; input x; datalines;\n1\n2\n";
    my $finding=scan_sas_text_for_unbalanced_constructs($bad)->{findings};
    is($finding->[0]{type}, 'unclosed_inline_data', "$entry detects missing inline-data terminator");
    is($finding->[0]{line}, 1, 'diagnostic identifies declaration line');
    $finding=scan_sas_text_for_unbalanced_constructs('data x; input x; datalines;')->{findings};
    is($finding->[0]{type}, 'unclosed_inline_data', 'declaration at EOF still requires a terminator');
    is($finding->[0]{line}, 1, 'EOF declaration line is accurate');
    $bad="data x; text='datalines;'; run;\ntext='unclosed;";
    $finding=scan_sas_text_for_unbalanced_constructs($bad)->{findings};
    is($finding->[0]{type}, 'unclosed_single_quote', 'declaration text inside a string does not hide a real quote error');
    $bad="/* datalines; */\ndata x; text='unclosed;";
    $finding=scan_sas_text_for_unbalanced_constructs($bad)->{findings};
    is($finding->[0]{type}, 'unclosed_single_quote', 'declaration text inside a comment does not hide a real quote error');
    $bad="data x; input x; datalines;\n1\n;\n/* unclosed";
    $finding=scan_sas_text_for_unbalanced_constructs($bad)->{findings};
    is($finding->[0]{type}, 'unclosed_block_comment', 'real malformed SAS after inline data remains detectable');
    is($finding->[0]{line}, 4, 'source line after inline data is accurate');
    my $raw="data x; input text \$; datalines4;\n%put literal; ordinary data;\n%macorparas\ndatalines; raw text\n;;;;\nrun;";
    is_deeply(scan_sas_text_for_unsafe_put_semicolons($raw), [], 'raw percent PUT text is not a SAS compile blocker');
    is_deeply(scan_sas_text_for_common_macro_typos($raw), [], 'raw macro-like spelling does not trigger a typo warning');
    is_deeply(scan_sas_text_for_inline_data_step_cards($raw), [], 'raw declaration-like spelling does not trigger an inline-card warning');
    is(scalar @{scan_sas_text_for_unsafe_put_semicolons('%put real; unquoted prose;')}, 1, 'real unsafe PUT remains detectable');
}
done_testing();
