#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../MCPDeps";
use SAS_Source_Analysis;
use Test::More;
for my $api ('call execute','rc=dosubl') {
    my $literal="data _null_; $api('%let text=%nrstr(%literal_never_called());'); run;";
    my $view=SAS_Source_Analysis::macro_dependency_view($literal);
    unlike($view,qr/%literal_never_called/,'deferred NRSTR body does not request dependencies');
    is(length($view),length($literal),'deferred mask preserves source offsets');
    my $real="data _null_; $api('%let text=%bquote(%real_dependency());'); run;";
    like(SAS_Source_Analysis::macro_dependency_view($real),qr/%real_dependency/,'real evaluated deferred dependency retained');
    my $data="data _null_; $api('data x; value=''\%ordinary_literal()''; run;'); run;";
    unlike(SAS_Source_Analysis::macro_dependency_view($data),qr/%ordinary_literal/,'decoded single-quoted DATA text remains literal');
    my $include="data _null_; $api('%include \"actual.sas\";'); run;";
    is_deeply(SAS_Source_Analysis::include_targets($include),['actual.sas'],'active deferred double-quoted include retained');
    my $quoted="data _null_; $api('data x; value=\"%real_double_quote()\"; run;'); run;";
    like(SAS_Source_Analysis::macro_dependency_view($quoted),qr/%real_double_quote/,'decoded evaluated double-quoted dependency retained');
}
done_testing();
