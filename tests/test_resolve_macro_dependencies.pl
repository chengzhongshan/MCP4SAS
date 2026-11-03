#!/usr/bin/env perl
use strict; use warnings;
use FindBin qw($Bin);
use lib "$Bin/../MCPDeps";
use SAS_Source_Analysis;
use Test::More;
for my $source (
    q{data x; text=resolve('%needed_macro()'); run;},
    q{data x; text=RESOLVE(strip('%needed_macro()')); run;},
    q{data x; text=resolve('%needed_macro(str='||value||')'); run;},
) {
    my $view=SAS_Source_Analysis::macro_dependency_view($source);
    like($view,qr/%needed_macro\b/,'RESOLVE macro expression is a real loading dependency');
    is(length $view,length $source,'source offsets remain stable');
    is_deeply(SAS_Source_Analysis::include_targets($source),[],'macro expression is not an include-file operand');
}
for my $source (
    q{data x; text='%never_called()'; run;},
    q{data x; text=resolve('&x')||'%never_called()'; run;},
    q{data x; text=myresolve('%never_called()'); run;},
    q{data x; text='resolve('||'%never_called()'; run;},
    q{data x; text=resolve('%nrstr(%never_called())'); run;},
) {
    unlike(SAS_Source_Analysis::macro_dependency_view($source),qr/%never_called\b/,
        'ordinary data, completed calls, unrelated functions and NRSTR stay masked');
}
is_deeply(SAS_Source_Analysis::include_targets(q{data x; text=resolve('%include "text_only.sas";'); run;}),[],
    'RESOLVE is not mistaken for DOSUBL or CALL EXECUTE include execution');
is_deeply(SAS_Source_Analysis::include_targets(q{data x; rc=dosubl('%include "actual.sas";'); run;}),['actual.sas'],
    'full deferred-code include discovery is preserved');
done_testing();
