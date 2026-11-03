#!/usr/bin/env perl
use strict; use warnings;
use FindBin qw($Bin);
use lib "$Bin/../MCPDeps";
use SAS_Source_Analysis;
use Test::More;
my $direct=q{%include 'first.sas' 'second.sas';};
my $deferred=q{data _null_; call execute('%include ''third.sas'' ''fourth.sas'';'); run;};
my $nested=q{data _null_; rc=dosubl('data _null_; call execute(''%include ''''fifth.sas'''';''); run;'); run;};
is_deeply(SAS_Source_Analysis::include_targets("$direct\n$deferred\n$nested\n%include 'sixth.sas';"),
    [qw(first.sas second.sas third.sas fourth.sas fifth.sas sixth.sas)],
    'direct, deferred, multi-operand and nested include dependencies retain lexical source order');
is_deeply(SAS_Source_Analysis::include_targets("$deferred\n$direct"),
    [qw(third.sas fourth.sas first.sas second.sas)],'deferred code before direct includes remains first');
is_deeply(SAS_Source_Analysis::include_targets(q{%include 'same.sas'; data _null_; rc=dosubl('%include ''middle.sas'';'); run; %include 'same.sas';}),
    [qw(same.sas middle.sas same.sas)],'repeated includes are preserved at their original positions');
is_deeply(SAS_Source_Analysis::include_targets(q{/* %include 'ignored.sas'; */ %include 'real.sas'; data _null_; text='%include ''data.sas'';'; run;}),
    ['real.sas'],'comments and nonexecutable literals remain excluded');
done_testing();
