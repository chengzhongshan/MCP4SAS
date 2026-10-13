#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../MCPDeps";
use SAS_Source_Analysis;
use Test::More;
my $findings=SAS_Source_Analysis::fileref_name_issues("data x; run;\nfilename toolongref temp;");
is(scalar @$findings,1,'long literal fileref diagnosed');
is($findings->[0]{line},2,'correct source line retained');
like($findings->[0]{message},qr/8 characters/,'actual SAS fileref limit explained');
for my $code (q{filename eightref temp;},q{/* filename toolongref temp; */ data x; value='filename toolongref temp;'; run;},q{filename &dynamic_ref temp;}) {
    is_deeply(SAS_Source_Analysis::fileref_name_issues($code),[],'valid or nonliteral filenames are not diagnosed');
}
done_testing();
