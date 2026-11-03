#!/usr/bin/env perl
use strict; use warnings;
use FindBin qw($Bin); use lib "$Bin/../MCPDeps";
use SAS_Evaluation_Corpus; use Test::More;
my $case={id=>'J3501',expected_failure=>0,expected=>3,tolerance=>'1e-6',diagnostic=>undef};
my $hash=SAS_Evaluation_Corpus::contract_fingerprint($case);
like($hash,qr/^[a-f0-9]{64}$/,'contract has a SHA-256 fingerprint');
ok(SAS_Evaluation_Corpus::checked_contract($case,$hash),'unchanged evaluation contract is verified');
is(SAS_Evaluation_Corpus::checked_contract($case,undef),0,'legacy evidence is explicitly unverified');
for my $change ([expected=>4],[tolerance=>'1e-3'],[diagnostic=>'different error'],[expected_failure=>1]) {
    my %changed=(%$case,$change->[0]=>$change->[1]);
    ok(!eval {SAS_Evaluation_Corpus::checked_contract(\%changed,$hash);1},"changed $change->[0] cannot inherit an old verdict");
    like($@,qr/Evaluation contract mismatch J3501/,'failure identifies the affected case');
}
ok(!eval {SAS_Evaluation_Corpus::checked_contract($case,'');1},'empty fingerprint is rejected');
ok(!eval {SAS_Evaluation_Corpus::checked_contract($case,'not-a-hash');1},'invalid fingerprint is rejected');
is(SAS_Evaluation_Corpus::contract_fingerprint({%$case,diagnostic=>''}),$hash,'absent and empty unused diagnostic are equivalent');
is(SAS_Evaluation_Corpus::contract_fingerprint({%$case,expected_failure=>undef}),$hash,'false classification is normalized');
is(SAS_Evaluation_Corpus::contract_fingerprint({%$case,evidence=>{book_title=>'another title'}}),$hash,'non-executable source attribution does not change the oracle contract');
my $negative={id=>'J3951',expected_failure=>1,diagnostic=>'more than one row',expected=>undef};
my $negative_hash=SAS_Evaluation_Corpus::contract_fingerprint($negative);
ok(SAS_Evaluation_Corpus::checked_contract($negative,$negative_hash),'negative diagnostic contract is verified');
ok(!eval {SAS_Evaluation_Corpus::checked_contract({%$negative,diagnostic=>'.*'},$negative_hash);1},'broader negative matcher requires new evidence');
done_testing();
