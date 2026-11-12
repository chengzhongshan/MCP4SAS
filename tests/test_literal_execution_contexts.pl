#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../MCPDeps";
use SAS_Source_Analysis;
use Test::More;

# Preserve the previous scanner as an independent regression oracle.
sub prefix_context {
    my ($analysis, $span, $macro_evaluation) = @_;
    my $prefix = substr($analysis->{masked}, 0, $span->{start});
    my $calls = $macro_evaluation
        ? qr/call\s+execute|dosubl|resolve/i
        : qr/call\s+execute|dosubl/i;
    my @stack;
    while ($prefix =~ /\b($calls)\s*\(|([()])/ig) {
        if (defined $1) { push @stack, 1; }
        elsif ($2 eq '(') { push @stack, 0; }
        else { pop @stack; }
    }
    return scalar grep { $_ } @stack;
}

my @sources = (
    q{data a; x='plain'; y="plain"; run;},
    q{data a; x=resolve(strip('%needed()')); y='%unused()'; run;},
    q{data a; rc=dosubl('%include "first.sas";'); run;},
    q{data a; call execute(cats('%first(', strip('value'), ');')); run;},
    q{data a; rc=dosubl(resolve('%outer()')); x='%after()'; run;},
    q{data a; rc=dosubl("%include 'second.sas';"); run;},
    q{data a; x='dosubl('; y='%inert()'; /* call execute('fake'); */ run;},
    q{data a; x=resolve('%nrstr(%protected())'); run;},
    q{data a; x=myresolve('%inert()'); rc=mydosubl('text'); run;},
    q{data a; x=resolve('escaped ''quote'' %needed()'); run;},
    q{data a; x="before"; call execute('%next()'); y='after'; run;},
    q{data a; x=call 'masked' execute ('edge'); run;},
);
push @sources, join "\n", map {
    "data t$_; a='label $_'; b=resolve('%needed$_()'); " .
    "c=dosubl('%include \"part$_.sas\";'); d='after'; run;"
} 1..80;

for my $index (0..$#sources) {
    my $analysis = SAS_Source_Analysis::analyze_source($sources[$index]);
    # Reverse requests deliberately to test that the cache is order independent.
    my @spans = reverse (@{$analysis->{single_quotes}}, @{$analysis->{double_quotes}});
    for my $mode (0, 1) {
        my @expected = map { prefix_context($analysis, $_, $mode) } @spans;
        my @actual = map { SAS_Source_Analysis::_literal_is_executable($analysis, $_, $mode) } @spans;
        is_deeply(\@actual, \@expected, "source $index mode $mode preserves all literal contexts");
    }
}
is_deeply(
    SAS_Source_Analysis::include_targets(q{call execute('%include "a.sas";'); x=resolve('%include "inert.sas";'); rc=dosubl("%include 'b.sas';");}),
    ['a.sas', 'b.sas'],
    'executable include order preserved and RESOLVE remains macro evaluation only',
);
done_testing();
