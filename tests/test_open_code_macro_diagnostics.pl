#!/usr/bin/env perl
use strict; use warnings; use FindBin qw($Bin); use lib "$Bin/../MCPDeps";
use SAS_Source_Analysis; use SAS_Log_Diagnostics; use SAS_Evaluation_Log; use SAS_Evaluation_Corpus; use JSON::PP qw(decode_json); use Test::More;
for my $source (
    '%if 1 %then /* comments are whitespace */ %do; %put okay; %end;',
    '%macro m; %local x; %do i=1 %to 3; %if &i %then %do; %end; %end; %mend;',
    '%let text=%nrstr(%local foo; %do i=1 %to 2; %end;);',
    q{data a; text='%if 1 %then %put no; %local foo;'; run;},
    "data a; input line \$char80.; datalines;\n%local x; %goto done;\n;\nrun;"
) {is_deeply(SAS_Source_Analysis::open_code_macro_issues($source),[],'valid, quoted, commented and raw-record controls stay unblocked');}
my $missing=SAS_Source_Analysis::open_code_macro_issues("%if 1 %then %do;\n%put pending;");
is($missing->[0]{type},'unclosed_open_code_do','unclosed open group detected before submission');
is($missing->[0]{line},1,'opening line retained');
my $recursion=SAS_Source_Analysis::open_code_macro_issues("/* comment */\n%let a=b\n%put &a;");
is($recursion->[0]{type},'macro_statement_recursion','missing semicolon identified'); is($recursion->[0]{line},2,'recursion refers to unterminated statement');
my $summary=SAS_Log_Diagnostics::summarize(<<'LOG');
=== Submitted SAS Codes or file ===
WARNING: Apparent symbolic reference INERT not resolved.
=== SAS Log ===
22 ERROR: The %LOCAL statement is not valid in open code.
ERROR: The %LOCAL statement is not valid in open code.
ERROR: Open code statement recursion detected.
WARNING: Apparent symbolic reference MISSING not resolved.
WARNING: Apparent invocation of macro ABSENT not resolved.
WARNING: Apparent symbolic reference MISSING not resolved.
=== Output ===
ERROR: The %RETURN statement is not valid in open code.
LOG
is($summary->{macro_count},4,'actual macro diagnostics grouped and deduplicated, echoes excluded');
is($summary->{warning_count},2,'macro warnings retain SAS warning severity');
is_deeply([map {$_->{kind}} @{$summary->{macro_diagnostics}}],[qw(open_code_control open_code_recursion unresolved_macro_variable unresolved_macro_invocation)],'specific categories retained');
like(SAS_Log_Diagnostics::format_summary($summary),qr/Hint:.*missing semicolon/,'MCP summary explains likely recursion cause');
is(SAS_Log_Diagnostics::summarize("35 WARNING: Apparent invocation of macro ECHO not resolved.\n")->{macro_count},0,'source listing cannot create a macro warning');
sub eval_warning {my ($log)=@_; SAS_Evaluation_Log::evaluate(report=>"=== SAS Log ===\n$log\n=== Output ===\n",marker=>'ROUND9_PASS',expected=>['M4046'],exit_code=>0,warning_pattern=>'apparent symbolic reference.*not resolved');}
ok(eval_warning("WARNING: Apparent symbolic reference MISSING not resolved.\nROUND9_PASS=M4046")->{passes}{M4046},'warning case requires actual warning plus success marker');
ok(!eval_warning('ROUND9_PASS=M4046')->{passes}{M4046},'warning case cannot pass on success marker alone');
ok(!eval_warning("12 WARNING: Apparent symbolic reference MISSING not resolved.\nROUND9_PASS=M4046")->{passes}{M4046},'echoed warning cannot satisfy the warning oracle');
open my $f,'<',"$Bin/library500_round8/manifest.json" or die $!; my $m=do {local $/; decode_json(<$f>)}; close $f;
open $f,'<',"$Bin/library500_round8/verified_results_2026-11-02.json" or die $!; my $r=do {local $/; decode_json(<$f>)}; close $f;
is(SAS_Evaluation_Corpus::contract_fingerprint($m->{cases}[0]),$r->{results}[0]{contract_sha256},'existing round-eight contract hashes remain compatible');
my $case={%{$m->{cases}[0]},warning_pattern=>'missing'};
isnt(SAS_Evaluation_Corpus::contract_fingerprint($case),$r->{results}[0]{contract_sha256},'new warning requirement is part of the evaluation contract');
my $timeout=SAS_Evaluation_Log::evaluate(report=>"=== SAS Log ===\nERROR: Expected %DO not found.\n=== Output ===\n",marker=>'ROUND9_PASS',expected=>['M4035'],exit_code=>1,
    expected_failure=>1,diagnostic=>'Expected %DO not found',status=>{state=>'failed',complete=>1,success=>0,message=>'SAS script timed out after 120s'},require_status=>1);
ok($timeout->{infrastructure_failure},'real wrapper timeout message is recognized even when the wrapper exits 1');
ok(!$timeout->{passes}{M4035},'partial matching macro error cannot turn an exit-1 timeout into an expected program-error pass');
is(SAS_Log_Diagnostics::summarize("ERROR: Expected %DO not found.\n")->{macro_diagnostics}[0]{kind},'open_code_control','expected DO error receives the open-code hint');
my %policy=(report=>"=== SAS Log ===\nWARNING: Apparent invocation of macro ABSENT not resolved.\nROUND9_PASS=M4047\n=== Output ===\n",marker=>'ROUND9_PASS',expected=>['M4047'],exit_code=>1,
    policy_failure=>1,warning_pattern=>'apparent invocation.*not resolved',status=>{state=>'failed',complete=>1,success=>0},require_status=>1);
ok(SAS_Evaluation_Log::evaluate(%policy)->{passes}{M4047},'explicit strict policy failure is verified separately from a SAS ERROR');
ok(!SAS_Evaluation_Log::evaluate(%policy,policy_failure=>0)->{passes}{M4047},'ordinary warning success cannot inherit a failed wrapper result');
ok(!SAS_Evaluation_Log::evaluate(%policy,exit_code=>0)->{passes}{M4047},'policy test requires the protective failed wrapper exit');
ok(!eval {SAS_Evaluation_Log::evaluate(%policy,warning_pattern=>undef);1},'policy failure requires its specific warning diagnostic');
done_testing();
