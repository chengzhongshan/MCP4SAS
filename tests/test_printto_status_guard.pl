#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../MCPDeps";
use SAS_ODA_Runner;
use Test::More;
my $plain='data x; value=1; run;';
is(SAS_ODA_Runner::_guard_redirected_sas_log($plain),$plain,'ordinary submissions retain their source');
for my $code (q{/* proc printto log=somewhere; */ data x; run;},q{data x; value='proc printto log=somewhere;'; run;},"data x; input; datalines;\nproc printto log=somewhere;\n;\nrun;") {
    is(SAS_ODA_Runner::_guard_redirected_sas_log($code),$code,'literal/comment/inline records do not trigger PRINTTO guard');
}
my $redirect=q{filename ownlog temp; proc printto log=ownlog new; run; data x; set absent; run; proc printto; run;};
my $guarded=SAS_ODA_Runner::_guard_redirected_sas_log($redirect);
like($guarded,qr/^%let syscc=0;/,'stale previous job condition code reset');
like($guarded,qr/\Q$redirect\E/,'submitted program preserved');
like($guarded,qr/proc printto;\s*run;\s*%macro.*?SYSCC/is,'log restored before condition-code reporting');
like($guarded,qr/%if.*?syscc.*?>=\s*8.*?%put ERROR:/is,'error condition codes report fatal errors while warnings remain nonfatal');
done_testing();
