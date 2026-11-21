use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../MCPDeps";
use SAS_Source_Analysis;
use Test::More;
for my $entry(qw(run_sas_codes_or_files_in_ODA.pl run_sas_codes_or_script_in_ODA.pl)) {
    open my $fh,'<',"$FindBin::Bin/../$entry" or die $!;
    my $source=do {local $/;<$fh>};
    for my $name(qw(_blank_preserving_newlines sanitize_sas_text_for_macro_lint _count_newlines scan_sas_text_for_macro_invocation_spans)) {
        my ($function)=$source =~ /^(sub \Q$name\E \{.*?^\})/ms;
        die "Missing $name" unless $function;
        no warnings 'redefine';eval $function;die $@ if $@;
    }
    my $spans=scan_sas_text_for_macro_invocation_spans('%outer(%inner(a), b);');
    is_deeply([map {[$_->{name},$_->{start_line},$_->{end_line},$_->{closed}]} @$spans], [['inner',1,1,1],['outer',1,1,1]], "$entry nested invocations retain closing order");
    is_deeply(scan_sas_text_for_macro_invocation_spans(q{'%ignored('; /* %comment( */}), [], "$entry inert invocations remain masked");
    $spans=scan_sas_text_for_macro_invocation_spans("%space \n\t (x)");
    is_deeply([map {[$_->{name},$_->{start_line},$_->{end_line},$_->{closed}]} @$spans],[['space',1,2,1]], "$entry multiline call retains line numbers");
    $spans=scan_sas_text_for_macro_invocation_spans(('x = 1;' . "\n") x 30000 . "%open(\nvalue");
    is(scalar @$spans,1,"$entry scans a large preamble without losing the final call");
    is($spans->[0]{start_line},30001,"$entry large-source diagnostic line is correct");
    ok(!$spans->[0]{closed},"$entry still detects missing closing parentheses");
}
done_testing;
