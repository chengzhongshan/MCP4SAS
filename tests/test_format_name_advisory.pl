#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../MCPDeps";
use SAS_Source_Analysis;
use Test::More;
my $issues=SAS_Source_Analysis::format_name_issues("proc format;\nvalue bad1 1='one';\ninvalue bad2 'x'=1;\nrun;");
is(scalar @$issues,2,'numeric and character-input definitions receive advisories');
is($issues->[0]{line},2,'format declaration line preserved');
is($issues->[1]{line},3,'informat declaration line preserved');
like($issues->[0]{message},qr/letter suffix/,'advisory suggests a concrete correction');
is_deeply(SAS_Source_Analysis::format_name_issues(q{proc format; value good1fmt 1='one'; value $goodchar 'Y'='yes'; run;}),[],'letter suffixes and character formats accepted');
is_deeply(SAS_Source_Analysis::format_name_issues(q{data x; value bad1; run;}),[],'VALUE text outside PROC FORMAT is not classified');
is_deeply(SAS_Source_Analysis::format_name_issues(q{/* proc format; value bad1; run; */}),[],'commented definitions ignored');
is_deeply(SAS_Source_Analysis::format_name_issues(q{proc format; value &dynamic_name 1='one'; run;}),[],'unresolved dynamic names are not guessed');
done_testing();
