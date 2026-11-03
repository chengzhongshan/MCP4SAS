#!/usr/bin/env perl
use strict; use warnings;
use FindBin qw($Bin); use lib "$Bin/../MCPDeps";
use SAS_Source_Analysis; use Test::More;
for my $case (
    [q{%inc 'one.sas';},['one.sas']],
    [q{%INC 'one.sas' "two.sas" / source2;},['one.sas','two.sas']],
    [q{%include 'first.sas'; data _null_; rc=dosubl('%inc ''second.sas'';'); run; %inc 'third.sas';},[qw(first.sas second.sas third.sas)]],
    [q{%inc 'author''s.sas';},[q{author's.sas}]],
    [q{data _null_; call execute('%INC "deferred.sas";'); run;},['deferred.sas']],
    [q{%inc fref;},[]],
    [q{%incidental 'not-an-include.sas';},[]],
    [q{/* %inc 'comment.sas'; */ data x; value='%inc ''literal.sas'';'; run;},[]],
    [q{%let sample=%nrstr(%inc 'inert.sas';);},[]],
) {is_deeply(SAS_Source_Analysis::include_targets($case->[0]),$case->[1],$case->[0]);}
for my $entry (qw(run_sas_codes_or_files_in_ODA.pl run_sas_codes_or_script_in_ODA.pl)) {
    open my $fh,'<',"$Bin/../$entry" or die $!; my $text=do {local $/; <$fh>}; close $fh;
    for my $name (qw(sas_submission_contains_include is_builtin_macro_name sas_submission_uses_nonbuiltin_macro)) {
        my ($sub)=$text=~/^(sub \Q$name\E \{.*?^\})/ms; die "Missing $name" unless $sub;
        no warnings 'redefine'; eval $sub; die $@ if $@;
    }
    ok(sas_submission_contains_include(q{%inc 'source.sas';}),"$entry recognizes abbreviated submission");
    ok(is_builtin_macro_name('INC'),"$entry excludes INC from external macro loading");
    ok(!sas_submission_contains_include(q{%incidental 'source.sas';}),"$entry requires keyword boundary");
    for my $name (qw(qscan qsubstr qupcase qlowcase nrquote index symdel sysmacdelete syscall symglobl symlocal)) {
        ok(is_builtin_macro_name(uc $name),"$entry recognizes reserved $name");
    }
    ok(!sas_submission_uses_nonbuiltin_macro(q{%let x=%qscan(%str(a,b),1,%str(,)); %symdel x;}),"$entry avoids external macro path for quoting builtins");
}
open my $runner,'<',"$Bin/../MCPDeps/SAS_ODA_Runner.pm" or die $!; my $runner_text=do {local $/; <$runner>}; close $runner;
my ($classifier)=$runner_text=~/^(sub _is_builtin_macro_name \{.*?^\})/ms; die 'Missing runner classifier' unless $classifier;
eval $classifier; die $@ if $@;
ok(_is_builtin_macro_name($_),"runner recognizes reserved $_") for qw(inc qscan qsubstr qupcase qlowcase nrquote index symdel sysmacdelete syscall symglobl symlocal);
ok(!_is_builtin_macro_name('user_defined_helper'),'runner retains user macro discovery');
done_testing();
