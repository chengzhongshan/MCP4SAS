#!/usr/bin/env perl
use strict; use warnings;
use FindBin qw($Bin);
use lib "$Bin/../MCPDeps";
use SAS_Source_Analysis;
use Test::More;
for my $source (
    q{%let x=%unquote(%nrstr(%released_macro()));},
    q{%let x=%UNQUOTE(%NRSTR(%released_macro()));},
    q{%let x=%unquote(%str(prefix)%nrstr(%released_macro()));},
    q{data _null_; text=resolve('%unquote(%nrstr(%released_macro()))'); run;},
    q{data x; text="%unquote(%nrstr(%released_macro()))"; run;},
) {
    my $view=SAS_Source_Analysis::macro_dependency_view($source);
    like($view,qr/%released_macro\b/,'UNQUOTE releases protected macro dependency');
    is(length($view),length($source),'release analysis preserves offsets');
}
for my $source (
    q{%let x=%nrstr(%not_released());},
    q{%let x=%nrstr(%unquote(%nrstr(%not_released())));},
    q{%let x=%unquote(%nrstr(%nrstr(%not_released())));},
    q{data x; text='%unquote(%nrstr(%not_released()))'; run;},
    q{/* %unquote(%nrstr(%not_released())) */},
) {
    unlike(SAS_Source_Analysis::macro_dependency_view($source),qr/%not_released\b/,
        'outer protection, inert data and comments remain masked');
}
done_testing();
