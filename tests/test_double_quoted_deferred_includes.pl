#!/usr/bin/env perl
use strict; use warnings;
use FindBin qw($Bin); use lib "$Bin/../MCPDeps"; use SAS_Source_Analysis; use Test::More;
for my $case (
    [q{data _null_; rc=dosubl("%include 'one.sas';"); run;},['one.sas']],
    [q{data _null_; CALL EXECUTE("%INC 'two.sas';"); run;},['two.sas']],
    [q{%include 'first.sas'; data _null_; rc=dosubl("%inc 'second.sas';"); run; %inc 'third.sas';},[qw(first.sas second.sas third.sas)]],
    [q{data _null_; rc=dosubl("%include ""quoted.sas"";"); run;},['quoted.sas']],
    [q{data _null_; rc=dosubl("%include 'author''s.sas';"); run;},[q{author's.sas}]],
    [q{data _null_; rc=dosubl("data _null_; rc=dosubl('%include ''nested.sas'';'); run;"); run;},['nested.sas']],
    [q{data _null_; call execute(cats("%include 'concat.sas';",' ')); run;},['concat.sas']],
    [q{data x; text="%include 'data.sas';"; run;},[]],
    [q{data x; text=dosubl('%let x=1;')||"%include 'outside.sas';"; run;},[]],
    [q{data x; text=resolve("%include 'macro_text.sas';"); run;},[]],
    [q{/* dosubl("%include 'comment.sas';") */},[]],
) {is_deeply(SAS_Source_Analysis::include_targets($case->[0]),$case->[1],$case->[0]);}
done_testing();
