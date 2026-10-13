#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../MCPDeps";
use SAS_Source_Analysis;
use Test::More;
for my $entry (qw(run_sas_codes_or_files_in_ODA.pl run_sas_codes_or_script_in_ODA.pl)) {
    open my $fh,'<',"$Bin/../$entry" or die $!;
    my $source=do {local $/; <$fh>}; close $fh;
    for my $name (qw(_blank_preserving_newlines sanitize_sas_text_for_macro_lint scan_sas_text_for_open_code_macro_control _count_newlines scan_sas_text_for_macro_invocation_spans scan_sas_text_for_unclosed_macro_invocations suppress_balanced_macro_invocation_false_positives scan_sas_text_for_unbalanced_constructs scan_sas_text_for_unsafe_put_semicolons scan_sas_text_for_common_macro_typos)) {
        my ($function)=$source =~ /^(sub \Q$name\E \{.*?^\})/ms;
        die "Missing $name" unless $function;
        no warnings 'redefine'; eval $function; die $@ if $@;
    }
    for my $code (
        "%macro demo;\ndata x; text='/*'; run;\n/* real comment */\n%mend;",
        "data x; * author's note; value=1; run;",
        "options notes; %* author's macro comment; data x; value=1; run;",
        "data x; text='it''s /* text */'; run;",
    ) {
        is_deeply(scan_sas_text_for_unbalanced_constructs($code)->{findings},[],"$entry accepts quoted/inline comment syntax");
    }
    my $commented="/*\n%put sample; ordinary prose;\n%macorparas\n*/";
    is_deeply(scan_sas_text_for_unsafe_put_semicolons($commented),[],'commented PUT example is not a compile blocker');
    is_deeply(scan_sas_text_for_common_macro_typos($commented),[],'commented spelling does not trigger a macro warning');
    my $bad="data x; text='/*'; run;\n/* genuinely unclosed";
    my $finding=scan_sas_text_for_unbalanced_constructs($bad)->{findings};
    is($finding->[0]{type},'unclosed_block_comment','literal opener does not conceal real unterminated comment');
    is($finding->[0]{line},2,'real comment line preserved');
    $finding=scan_sas_text_for_unbalanced_constructs("data x; * author's note; value='unclosed; run;")->{findings};
    is($finding->[0]{type},'unclosed_single_quote','inline comment does not conceal genuine quoted-string error');
    $finding=scan_sas_text_for_unbalanced_constructs("data x; value=2 %* explanation; * 'unclosed;")->{findings};
    is($finding->[0]{type},'unclosed_single_quote','macro comment inside an expression does not turn multiplication into a statement comment');
    is(scalar @{scan_sas_text_for_unsafe_put_semicolons('%put actual; unquoted prose;')},1,'real unsafe PUT is still detected');
    my $mask=SAS_Source_Analysis::mask_noncode($commented);
    is(length($mask),length($commented),'mask preserves source offsets');
    is(($mask =~ tr/\n//),($commented =~ tr/\n//),'mask preserves source line count');
}
done_testing();
