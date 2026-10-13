#!/usr/bin/env perl
use strict; use warnings;
use FindBin qw($Bin);
use lib "$Bin/../MCPDeps";
use SAS_Source_Analysis;
use SAS_ODA_Runner;
use Test::More;
for my $case (
 [q{%include 'author''s file.sas';},q{author's file.sas}],
 [q{data _null_; rc=dosubl('%include ''actual.sas'';'); run;},'actual.sas'],
 [q{data _null_; call execute('%include ''actual.sas'';'); run;},'actual.sas'],
 [q{data _null_; rc=dosubl('%include ''author''''s file.sas'';'); run;},q{author's file.sas}],
 [q{data _null_; call execute('data x; run;'||'%include ''next.sas'';'); run;},'next.sas']) {
    is_deeply(SAS_Source_Analysis::include_targets($case->[0]),[$case->[1]],'quoted/deferred include resolves to actual path');
}
for my $code (q{data x; text='%include ''literal.sas'';'; run;},q{data _null_; rc=dosubl('%let x=%nrstr(%include ''literal.sas'';);'); run;},q{/* %include 'comment.sas'; */}) {
    is_deeply(SAS_Source_Analysis::include_targets($code),[],'inactive include text remains ignored');
}
my $outside=q{data x; text=dosubl('%let x=1;')||'%outside_literal()'; run;};
unlike(SAS_Source_Analysis::macro_dependency_view($outside),qr/%outside_literal/,'literal after completed DOSUBL call remains ordinary data');
my $rewritten=SAS_ODA_Runner::_replace_dependency_path(q{%include 'author''s.sas'; rc=dosubl('%include ''author''''s.sas'';');},q{author's.sas},q{/home/user/author's.sas});
like($rewritten,qr{%include '/home/user/author''s.sas'},'direct apostrophe escaping preserved');
like($rewritten,qr{%include ''/home/user/author''''s.sas''},'deferred apostrophe escaping preserved');
done_testing();
