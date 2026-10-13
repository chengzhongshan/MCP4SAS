#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../MCPDeps";
use SAS_Log_Diagnostics;
use Test::More;

my $summary = SAS_Log_Diagnostics::summarize(<<'LOG');
=== Submission Preflight ===
WARNING: preflight sample must not be counted
=== SAS Log ===
12  put 'WARNING: ordinary source text';
MPRINT(DEMO): put 'WARNING: ordinary data';
SYMBOLGEN: Macro variable X resolves to WARNING: ordinary data
WARNING: Variable value has different types on BASE and DATA files.
WARNING: Variable value has different types on BASE and DATA files.
NOTE: Invalid data for amount in line 94 3-5.
id=2 amount=. _ERROR_=1 _N_=2
NOTE: Division by zero detected at line 3 column 5.
NOTE: Mathematical operations could not be performed.
NOTE: There were 3 observations read from the data set WORK.X.
=== Output ===
WARNING: sample after the SAS log must not be counted
LOG
is($summary->{warning_count}, 1, 'runtime warnings are deduplicated, source/preflight/output excluded');
is($summary->{data_quality_count}, 4, 'invalid input, runtime error flag and arithmetic notes are surfaced');
like(SAS_Log_Diagnostics::format_summary($summary), qr/1 warning\(s\), 4 data-quality/, 'summary includes separate counts');
unlike(SAS_Log_Diagnostics::format_summary($summary), qr/3 observations/, 'routine NOTES are excluded');
is(SAS_Log_Diagnostics::format_summary(SAS_Log_Diagnostics::summarize('')), '', 'no diagnostics for empty log');
is(SAS_Log_Diagnostics::summarize("NOTE: Numeric values have been converted to character values.\n")->{data_quality_count}, 1, 'raw SAS log supported');
is(SAS_Log_Diagnostics::summarize("23  _ERROR_=1;\nMPRINT(T): _ERROR_=1;\n")->{data_quality_count}, 0, 'source assignment does not masquerade as runtime input error');
my $flowover=SAS_Log_Diagnostics::summarize("NOTE: SAS went to a new line when INPUT statement reached past the end of a line.\nNOTE: No observations in data set WORK.E150.\n");
is($flowover->{data_quality_count},2,'flowover and empty procedure input are surfaced');
like($flowover->{data_quality}[0],qr/INPUT statement/,'input-record loss diagnostic preserved');
is(SAS_Log_Diagnostics::summarize("23 NOTE: No observations in data set WORK.SOURCE.\n")->{data_quality_count},0,'empty-data note in a source listing is not counted');
is(SAS_Log_Diagnostics::summarize("NOTE: Variable n is uninitialized.\n")->{data_quality_count},1,'uninitialized variable is an advisory diagnostic');
is(SAS_Log_Diagnostics::summarize("42 NOTE: Variable n is uninitialized.\n")->{data_quality_count},0,'source listing does not fabricate an uninitialized-variable note');
done_testing();
