#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../MCPDeps";
use SAS_Source_Analysis;
use SAS_ODA_Runner;
use Test::More;
for my $code (q{%let x=%str(%');},q{%let x=%str(%();},q{%let x=%str(%));},q{%let x=%bquote(O'Brien);},q{%let x=%nrstr(alpha;beta);},q{%let x=%nrstr(%not_executed());}) {
    is_deeply(SAS_Source_Analysis::analyze_source($code)->{findings},[], 'valid macro quoting accepted');
    is(length(SAS_Source_Analysis::mask_noncode($code)),length($code),'macro-quote mask preserves offsets');
}
my $bad=SAS_Source_Analysis::analyze_source(q{%let x=%str(%(;});
is($bad->{findings}[0]{type},'unclosed_macro_invocation','missing macro-quote closing delimiter remains an error');
$bad=SAS_Source_Analysis::analyze_source("%let x=%str(%');\ndata x; value='unclosed;");
is($bad->{findings}[0]{type},'unclosed_single_quote','real source quote error after macro quoting remains visible');
is($bad->{findings}[0]{line},2,'line numbers after macro quoting preserved');
my $masked=SAS_Source_Analysis::mask_macro_literals(q{%let x=%nrstr(%not_executed()); %real_dependency;});
unlike($masked,qr/%not_executed/,'NRSTR literal call excluded from dependency parsing');
like($masked,qr/%real_dependency/,'real following dependency retained');
like(SAS_Source_Analysis::mask_macro_literals(q{%let x=%bquote(%evaluated_first());}),qr/%evaluated_first/,'BQUOTE evaluated dependency retained');
unlike(SAS_Source_Analysis::macro_dependency_view(q{data x; text='%literal_not_executed()'; run;}),qr/%literal_not_executed/,'single-quoted DATA text is not a macro dependency');
like(SAS_Source_Analysis::macro_dependency_view(q{data x; text="%evaluated_macro()"; run;}),qr/%evaluated_macro/,'double-quoted macro call remains a dependency');
like(SAS_Source_Analysis::macro_dependency_view(q{data _null_; call execute('%delayed_macro();'); run;}),qr/%delayed_macro/,'CALL EXECUTE code remains a dependency');
like(SAS_Source_Analysis::macro_dependency_view(q{data _null_; rc=dosubl('%immediate_macro();'); run;}),qr/%immediate_macro/,'DOSUBL code remains a dependency');
for my $entry (qw(run_sas_codes_or_files_in_ODA.pl run_sas_codes_or_script_in_ODA.pl)) {
    open my $fh,'<',"$Bin/../$entry" or die $!;
    my $source=do {local $/; <$fh>}; close $fh;
    for my $name (qw(is_builtin_macro_name sas_submission_uses_nonbuiltin_macro sas_submission_contains_include extract_include_targets)) {
        my ($function)=$source =~ /^(sub \Q$name\E \{.*?^\})/ms;
        no warnings 'redefine'; eval $function; die $@ if $@;
    }
    ok(!sas_submission_uses_nonbuiltin_macro(q{%let x=%nrstr(%not_executed());}),"$entry does not request macro bootstrap for an NRSTR literal");
    ok(sas_submission_uses_nonbuiltin_macro(q{%let x=%bquote(%evaluated_first());}),"$entry retains evaluated macro bootstrap detection");
    ok(!sas_submission_contains_include(q{%let x=%nrstr(%include 'masked.sas';);}),"$entry excludes masked include directives");
    is_deeply([extract_include_targets(q{%let x=%nrstr(%include 'masked.sas';); %include "real's file.sas";})],[q{real's file.sas}],"$entry preserves an apostrophe inside a double-quoted include path");
    is_deeply([extract_include_targets(q{data x; value='%include "not executed.sas";'; run;})],[],"$entry ignores include-like single-quoted DATA text");
}
{
    local $ENV{SAS_ODA_AUTOLOAD_MACROS}=0;
    no warnings 'redefine';
    local *SAS_ODA_Runner::_find_local_macro_file=sub {return};
    my $runner=bless {},'SAS_ODA_Runner';
    my ($code,$logs)=$runner->_process_dependencies(q{%let x=%nrstr(%not_executed()); %real_dependency;});
    unlike($code,qr/not_executed\.sas/,'runner does not inject a loader for a masked literal');
    like($code,qr/real_dependency\.sas/,'runner still injects a loader for a real macro');
}
for my $code (
    q{%let x=%bquote(%nrstr(%nested_literal()));},
    q{data x; value="%nrstr(%nested_literal())"; run;},
    q{%let x=%quote(%bquote(%nrstr(%nested_literal())));}) {
    unlike(SAS_Source_Analysis::macro_dependency_view($code),qr/%nested_literal/,'nested NRSTR is excluded from dependencies');
    is_deeply(SAS_Source_Analysis::analyze_source($code)->{findings},[],'nested quoting remains valid source');
}
like(SAS_Source_Analysis::macro_dependency_view(q{%let x=%bquote(%quote(%real_nested()));}),qr/%real_nested/,'real nested evaluated dependency retained');
is_deeply(SAS_Source_Analysis::analyze_source(q{data x; value="%str(%")"; run;})->{findings},[],'escaped macro quote does not close outer double-quoted string');
done_testing();
