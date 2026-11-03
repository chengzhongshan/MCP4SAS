#!/usr/bin/env perl
use strict; use warnings;
use FindBin qw($Bin);
use lib "$Bin/../MCPDeps";
use SAS_Evaluation_Log;
use Test::More;
sub check {
    my ($log,%extra)=@_;
    return SAS_Evaluation_Log::evaluate(report=>"=== SAS Log ===\n$log\n=== Output ===\n",marker=>'ROUND4_PASS',
        expected=>['F1951'],expected_failure=>1,diagnostic=>'ambiguous',exit_code=>1,%extra);
}
ok(check('ERROR: Ambiguous reference to column x.')->{passes}{F1951},'specific runtime error and nonzero exit verify an intentional failure');
ok(!check('ERROR: Ambiguous reference to column x.',exit_code=>0)->{passes}{F1951},'zero exit is an error-reporting failure');
ok(!check('ERROR: Connection refused')->{passes}{F1951},'unrelated infrastructure error cannot satisfy expected SAS error');
ok(!check('12 ERROR: Ambiguous reference to column x.')->{passes}{F1951},'source echo cannot supply a runtime error');
ok(!check('WARNING: Ambiguous reference to column x.')->{passes}{F1951},'warning cannot satisfy required fatal diagnostic');
ok(!check('ERROR: Ambiguous reference to column x.',exit_code=>143)->{passes}{F1951},'signal termination is not a verified SAS failure');
ok(!check('ERROR: Ambiguous reference to column x.',exit_code=>undef)->{passes}{F1951},'missing process status fails closed');
ok(!check("ERROR: Ambiguous reference to column x.\nROUND4_PASS=F1951")->{passes}{F1951},'contradictory successful-calculation marker fails');
ok(!check('ERROR: Ambiguous reference to column x.',report=>"=== Submitted SAS Codes or file ===\nERROR: ambiguous\n")->{passes}{F1951},'missing SAS runtime log cannot pass');
my $bad=eval {check('ERROR: ambiguous',expected=>['A','B']); 1};
ok(!$bad,'expected failures must be isolated one per job');
ok(check('ERROR: ambiguous',require_status=>1,status=>{state=>'failed',success=>0,complete=>1})->{passes}{F1951},'terminal failure metadata agrees with runtime failure');
ok(!check('ERROR: ambiguous',require_status=>1,status=>{state=>'completed',success=>1,complete=>1})->{passes}{F1951},'contradictory success metadata cannot pass an intentional error');
ok(!check('ERROR: ambiguous',require_status=>1,status=>{state=>'failed',success=>0,complete=>0})->{passes}{F1951},'nonterminal status cannot pass');
ok(!check('ERROR: ambiguous',require_status=>1)->{passes}{F1951},'missing required metadata fails closed');
ok(!check('ROUND4_PASS=F1951',expected_failure=>0,exit_code=>0,require_status=>1,status=>{state=>'failed',success=>0,complete=>1})->{passes}{F1951},'positive assertion cannot override failed terminal metadata');
ok(!check('ERROR: ambiguous',exit_code=>74)->{passes}{F1951},'remote termination cannot pass even with a matching partial log');
ok(!check('ERROR: ambiguous',exit_code=>73)->{passes}{F1951},'space exhaustion cannot pass as a program error');
ok(!check('ERROR: ambiguous',exit_code=>124)->{passes}{F1951},'timeout exit cannot pass as a program error');
ok(!check('ERROR: ambiguous',status=>{failure_class=>'sas_oda_remote_session_termination'})->{passes}{F1951},'classified termination is rejected even if its exit code is overridden');
done_testing();
