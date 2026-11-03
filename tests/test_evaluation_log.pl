#!/usr/bin/env perl
use strict; use warnings;
use FindBin qw($Bin);
use lib "$Bin/../MCPDeps";
use SAS_Evaluation_Log;
use Test::More;
sub check {
    my ($log,%extra)=@_;
    return SAS_Evaluation_Log::evaluate(report=>"=== Submitted SAS Codes or file ===\nROUND2_PASS=R501\n=== SAS Log ===\n$log\n=== Output ===\nROUND2_PASS=R502\n",
        marker=>'ROUND2_PASS',expected=>['R501'],exit_code=>0,%extra);
}
ok(check('ROUND2_PASS=R501')->{passes}{R501},'one exact runtime marker establishes success');
ok(!check('')->{passes}{R501},'marker in submitted program cannot establish success');
ok(!check("12 ROUND2_PASS=R501\nMPRINT(X): ROUND2_PASS=R501")->{passes}{R501},'source and macro traces are not execution markers');
ok(!check("ROUND2_PASS=R501\nROUND2_PASS=R501")->{passes}{R501},'duplicate assertion markers fail');
ok(!check("ROUND2_PASS=R501\nROUND2_PASS=R999")->{passes}{R501},'unexpected case marker fails the batch');
ok(!check("ROUND2_PASS=R501\nROUND2_PASS=malformed")->{passes}{R501},'malformed marker IDs are not silently ignored');
ok(!check("ROUND2_PASS=R501\nERROR: calculation failed")->{passes}{R501},'runtime ERROR invalidates markers');
ok(!check("ROUND2_PASS=R501\n  ERROR 22-322: bad syntax")->{passes}{R501},'indented numbered SAS error invalidates markers');
ok(!check('ROUND2_PASS=R501',exit_code=>1)->{passes}{R501},'nonzero worker exit invalidates markers');
my $absent=SAS_Evaluation_Log::evaluate(report=>'ROUND2_PASS=R501',marker=>'ROUND2_PASS',expected=>['R501'],exit_code=>0);
ok(!$absent->{has_runtime_log} && !$absent->{passes}{R501},'missing runtime log fails closed');
ok(check("ROUND2_PASS=R501\nWARNING: advisory only")->{passes}{R501},'a warning does not change SAS fatal severity');
ok(check('ROUND2_PASS=R501',report=>"=== SAS Log ===\r\nROUND2_PASS=R501\r\n=== Output ===\r\n")->{passes}{R501},'CRLF logs are supported');
ok(SAS_Evaluation_Log::evaluate(report=>"=== SAS Log ===\nLIB500_PASS=L001\n=== Output ===\n",marker=>'LIB500_PASS',expected=>['L001'],exit_code=>0)->{passes}{L001},'previous round marker format remains supported');
done_testing();
