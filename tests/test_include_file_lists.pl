#!/usr/bin/env perl
use strict; use warnings;
use FindBin qw($Bin);
use lib "$Bin/../MCPDeps";
use SAS_Source_Analysis;
use Test::More;
for my $case (
 [q{%include 'first.sas' "second.sas";},['first.sas','second.sas']],
 [q{%include 'one.sas' /* separator */ 'two.sas' / source2;},['one.sas','two.sas']],
 [q{%include 'semi;colon.sas' 'author''s.sas';},['semi;colon.sas',q{author's.sas}]],
 [q{data _null_; rc=dosubl('%include ''first.sas'' ''second.sas'';'); run;},['first.sas','second.sas']],
 [q{data _null_; call execute('%include ''first.sas'' ''second.sas'';'); run;},['first.sas','second.sas']],
 [q{%include 'first.sas'; title 'unrelated.sas';},['first.sas']],
 [q{%include 'first.sas' / source2; title 'unrelated.sas';},['first.sas']],
 [q{data x; text='%include ''first.sas'' ''second.sas'';'; run;},[]],
 [q{%let x=%nrstr(%include 'first.sas' 'second.sas';);},[]],
 [q{/* %include 'first.sas' 'second.sas'; */},[]]) {
    is_deeply(SAS_Source_Analysis::include_targets($case->[0]),$case->[1],$case->[0]);
}
done_testing();
