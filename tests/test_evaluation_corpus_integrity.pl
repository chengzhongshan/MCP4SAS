#!/usr/bin/env perl
use strict; use warnings;
use FindBin qw($Bin); use lib "$Bin/../MCPDeps";
use SAS_Evaluation_Corpus; use Digest::SHA qw(sha256_hex); use JSON::PP qw(decode_json); use Test::More;
sub read_text {open my $f,'<:raw',$_[0] or die $!; local $/; return <$f>;}
my $source="/* test */\ndata b3001o; actual=2; put 'ROUND7_PASS=B3001'; run;\n";
my $body=$source; $body=~s{\A/\*[^\n]*\*/\n}{}; $body=~s/b\d{4}/bCASE/ig;
my $a={id=>'B3001',file=>'B3001.sas',expected=>2,body_sha256=>sha256_hex($body)};
my $b={%$a,id=>'B3002',file=>'B3002.sas'};
my $m={count=>2,cases=>[$a,$b]};
is(scalar @{SAS_Evaluation_Corpus::select_cases($m,'')},2,'default selects declared cases');
is_deeply([map {$_->{id}} @{SAS_Evaluation_Corpus::select_cases($m,' B3002 , B3001 ')}],[qw(B3001 B3002)],'whitespace accepted and manifest order preserved');
for my $bad ('B3001,B3001','B3009','B3001,',',') {ok(!eval {SAS_Evaluation_Corpus::select_cases($m,$bad);1},"invalid selection rejected: $bad");}
ok(!eval {SAS_Evaluation_Corpus::select_cases({count=>2,cases=>[$a,$a]},'');1},'duplicate manifest IDs rejected');
ok(!eval {SAS_Evaluation_Corpus::select_cases({count=>3,cases=>[$a,$b]},'');1},'count mismatch rejected');
ok(!eval {SAS_Evaluation_Corpus::select_cases({count=>1,cases=>[{%$a,file=>'../outside.sas'}]},'');1},'case filename mismatch rejected');
ok(!eval {SAS_Evaluation_Corpus::select_cases({count=>1,cases=>[{%$a,expected_failure=>1}]},'');1},'negative case needs diagnostic');
ok(!eval {SAS_Evaluation_Corpus::select_cases({count=>1,cases=>[{%$a,expected=>undef}]},'');1},'positive case needs oracle');
is(SAS_Evaluation_Corpus::checked_source($a,$source),$source,'verified source is returned unchanged');
(my $crlf=$source)=~s/\n/\r\n/g;
is(SAS_Evaluation_Corpus::checked_source($a,$crlf),$crlf,'CRLF is accepted without altering submitted bytes');
(my $changed=$source)=~s/actual=2/actual=3/;
ok(!eval {SAS_Evaluation_Corpus::checked_source($a,$changed);1},'edited numerical body cannot retain old provenance');
ok(!eval {SAS_Evaluation_Corpus::checked_source($a,'');1},'empty source rejected');
my $renamed=$source; $renamed=~s/b3001/H3001/ig; $renamed=~s/ROUND7_/ROUND6_/g;
my $renamed_body=$renamed; $renamed_body=~s{\A/\*[^\n]*\*/\n}{}; $renamed_body=~s/h\d{4}/hCASE/ig;
my $renamed_case={id=>'H3001',body_sha256=>sha256_hex($renamed_body)};
is(SAS_Evaluation_Corpus::behavior_fingerprint($a,$source),SAS_Evaluation_Corpus::behavior_fingerprint($renamed_case,$renamed),'renaming case and round does not create novelty');
my $different_body=$changed; $different_body=~s{\A/\*[^\n]*\*/\n}{}; $different_body=~s/b\d{4}/bCASE/ig;
isnt(SAS_Evaluation_Corpus::behavior_fingerprint($a,$source),SAS_Evaluation_Corpus::behavior_fingerprint({%$a,body_sha256=>sha256_hex($different_body)},$changed),'changed numerical input has a distinct fingerprint');
ok(!eval {SAS_Evaluation_Corpus::behavior_fingerprint($a,$changed);1},'novelty check also rejects stale source hashes');
for my $dir ('library500',map {"library500_round$_"} 2..8) {
    my $corpus=decode_json(read_text("$Bin/$dir/manifest.json")); my $case=$corpus->{cases}[0];
    ok(eval {SAS_Evaluation_Corpus::checked_source($case,read_text("$Bin/$dir/$case->{file}"));1},"existing $dir fingerprint convention supported");
}
done_testing();
