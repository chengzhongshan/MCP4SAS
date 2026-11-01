#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../MCPDeps";
use Cwd qw(abs_path);
use File::Path qw(make_path);
use File::Temp qw(tempdir);
use JSON::PP qw(encode_json);
use Test::More tests => 100;
use SAS_Source_Analysis;
use SAS_Log_Diagnostics;
use MCP4SAS_Temp;

my $task = 0;
sub task_name { return sprintf 'T%03d %s', ++$task, $_[0] }
sub task_is { my ($got,$want,$name)=@_; is($got,$want,task_name($name)); }
sub task_deep { my ($got,$want,$name)=@_; is_deeply($got,$want,task_name($name)); }
sub task_ok { my ($got,$name)=@_; ok($got,task_name($name)); }

# T001-T025: include discovery in source forms not covered by earlier suites.
my @include_cases = (
    [q{%include "alpha.sas";}, ['alpha.sas'], 'double-quoted direct include'],
    [q{%INCLUDE 'upper.sas';}, ['upper.sas'], 'case-insensitive include keyword'],
    [q{%include 'one.sas' "two.sas";}, ['one.sas','two.sas'], 'mixed-quote include list'],
    [q{%include 'one.sas' 'two.sas' / source2;}, ['one.sas','two.sas'], 'include list stops before options'],
    [q{%include 'author''s second.sas';}, [q{author's second.sas}], 'doubled apostrophe in direct path'],
    [q{%include 'semi;colon.sas';}, ['semi;colon.sas'], 'semicolon inside quoted path'],
    ["%include\n  'line-one.sas'\n  'line-two.sas'\n;", ['line-one.sas','line-two.sas'], 'multiline include list'],
    [q{%include 'first.sas'; %include 'second.sas';}, ['first.sas','second.sas'], 'two direct include statements'],
    [q{/* %include 'blocked.sas'; */}, [], 'block-comment include ignored'],
    [q{* %include 'statement-comment.sas';}, [], 'statement-comment include ignored'],
    [q{%* %include 'macro-comment.sas';}, [], 'macro-comment include ignored'],
    [q{data x; text="%include 'string.sas';"; run;}, [], 'double-quoted data include ignored'],
    [q{%include "&root./macro-path.sas";}, ['&root./macro-path.sas'], 'macro variable retained in include path'],
    [q{data _null_; rc=DOSUBL('%include ''deferred-upper.sas'';'); run;}, ['deferred-upper.sas'], 'uppercase DOSUBL include'],
    [q{data _null_; CALL EXECUTE('%include ''deferred-call.sas'';'); run;}, ['deferred-call.sas'], 'uppercase CALL EXECUTE include'],
    [q{data _null_; rc=dosubl('data _null_; rc=dosubl(''%include ''''nested.sas'''';''); run;'); run;}, ['nested.sas'], 'nested DOSUBL include'],
    [q{data x; y=dosubl('%let z=1;')||'%include ''outside.sas'';'; run;}, [], 'literal after closed DOSUBL ignored'],
    [q{data _null_; rc=dosubl('%let x=%nrstr(%include ''quoted.sas'';);'); run;}, [], 'NRSTR include remains inactive'],
    ["data x; input text \$; datalines;\n%include 'raw.sas';\n;\nrun;", [], 'DATALINES include text ignored'],
    ["data x; input text \$; cards4;\n%include 'raw4.sas';\n;;;;\nrun;", [], 'CARDS4 include text ignored'],
    [q{%include 'kept.sas' / source2; data x; text='later.sas'; run;}, ['kept.sas'], 'include options do not consume later literals'],
    [q{%include 'unterminated.sas;}, [], 'unterminated include path rejected'],
    [q{%include '';}, [], 'empty include path ignored'],
    [q{%include 'literal.sas' dynamic_operand;}, ['literal.sas'], 'literal retained before dynamic operand'],
    ["data x; input n; datalines;\n1\n;\nrun;\n%include 'after-data.sas';", ['after-data.sas'], 'include after inline data discovered'],
);
for my $case (@include_cases) {
    task_deep(SAS_Source_Analysis::include_targets($case->[0]),$case->[1],$case->[2]);
}

# T026-T050: literal format and fileref advisory boundaries.
my @format_cases = (
    [q{proc format; value fmt1 1='x'; run;}, 1, 'VALUE name ending in digit'],
    [q{proc format; invalue input2 'x'=1; run;}, 1, 'INVALUE name ending in digit'],
    [q{proc format; picture pic3 low-high='9'; run;}, 1, 'PICTURE name ending in digit'],
    [q{proc format; value $char4 'x'='y'; run;}, 1, 'character format ending in digit'],
    [q{proc format; value fmtA 1='x'; run;}, 0, 'format ending in letter accepted'],
    [q{proc format; value fmt_ 1='x'; run;}, 0, 'format ending in underscore accepted'],
    [q{/* proc format; value hidden1 1='x'; run; */}, 0, 'commented format ignored'],
    [q{data x; text="proc format; value hidden2 1='x'; run;"; run;}, 0, 'quoted format source ignored'],
    [q{data x; value outside3; run;}, 0, 'VALUE outside PROC FORMAT ignored'],
    [q{proc format; value first1 1='x'; invalue second2 'x'=2; run;}, 2, 'multiple invalid names reported'],
    ["data x;run;\nproc format;\nvalue line5 1='x';\nrun;", 3, 'format issue source line preserved'],
    [q{proc format; picture quit6 low-high='9'; quit;}, 1, 'QUIT terminates format procedure'],
    [q{proc format; value inside7 1='x'; run; value outside8;}, 1, 'RUN prevents advisory leakage'],
    [q{proc format; /* value hidden9 1='x'; */ value shown0 1='y'; run;}, 1, 'comment masking inside format body'],
    [q{PROC FORMAT; VALUE MIXED1 1='x'; RUN;}, 1, 'format parsing is case-insensitive'],
);
for my $case (@format_cases) {
    my $issues=SAS_Source_Analysis::format_name_issues($case->[0]);
    my $got=$case->[2] =~ /source line/ ? ($issues->[0]{line}//0) : scalar @$issues;
    task_is($got,$case->[1],$case->[2]);
}
my @fileref_cases = (
    [q{filename ninechars '/tmp/x';}, 1, 'nine-character fileref rejected'],
    [q{filename eightchr '/tmp/x';}, 0, 'eight-character fileref accepted'],
    [q{filename under_123 '/tmp/x';}, 1, 'long underscore fileref rejected'],
    [q{/* filename hiddenref9 '/tmp/x'; */}, 0, 'commented fileref ignored'],
    [q{data x; text="filename hiddenref8 '/tmp/x';"; run;}, 0, 'quoted fileref ignored'],
    ["data x;run;\nfilename line_ref9 '/tmp/x';", 2, 'fileref issue source line preserved'],
    [q{filename first_ref '/tmp/a'; filename secondref '/tmp/b';}, 2, 'multiple long filerefs reported'],
    [q{filename clear_ref clear;}, 1, 'long fileref CLEAR remains advisory'],
    [q{filename &dynamic '/tmp/x';}, 0, 'dynamic fileref not treated as literal'],
    [q{FiLeNaMe MixedCase9 '/tmp/x';}, 1, 'fileref parsing is case-insensitive'],
);
for my $case (@fileref_cases) {
    my $issues=SAS_Source_Analysis::fileref_name_issues($case->[0]);
    my $got=$case->[2] =~ /source line/ ? ($issues->[0]{line}//0) : scalar @$issues;
    task_is($got,$case->[1],$case->[2]);
}

# T051-T075: runtime diagnostics and wrapper-section isolation.
my @diagnostic_cases = (
    ["WARNING: plain runtime warning\n", 1, 0, 'plain warning counted'],
    ["WARNING 123-456: coded warning\n", 1, 0, 'coded warning counted'],
    ["warning: lowercase severity\n", 1, 0, 'warning matching is case-insensitive'],
    [" WARNING: trimmed warning \nWARNING: trimmed warning\n", 1, 0, 'trimmed duplicate warnings collapse'],
    ["12 WARNING: source listing\n", 0, 0, 'numbered warning source excluded'],
    ["MPRINT(X): WARNING: generated source\n", 0, 0, 'MPRINT warning source excluded'],
    ["NOTE: Invalid data for age in line 1.\n", 0, 1, 'invalid data note counted'],
    ["NOTE: Invalid argument to function INPUT.\n", 0, 1, 'invalid argument note counted'],
    ["NOTE: Variable amount is uninitialized.\n", 0, 1, 'uninitialized variable counted'],
    ["NOTE: Division by zero detected.\n", 0, 1, 'division by zero counted'],
    ["NOTE: Mathematical operations could not be performed.\n", 0, 1, 'math operation failure counted'],
    ["NOTE: Missing values were generated as a result.\n", 0, 1, 'generated missing values counted'],
    ["NOTE: Character values have been converted to numeric values.\n", 0, 1, 'character conversion counted'],
    ["NOTE: Numeric values have been converted to character values.\n", 0, 1, 'numeric conversion counted'],
    ["NOTE: SAS went to a new line when INPUT statement reached past the end of a line.\n", 0, 1, 'INPUT flowover counted'],
    ["NOTE: No observations in data set WORK.EMPTY.\n", 0, 1, 'empty data set counted'],
    ["id=4 amount=. _ERROR_=1 _N_=4\n", 0, 1, 'runtime error flag counted'],
    ["24 _ERROR_=1;\n", 0, 0, 'numbered error assignment excluded'],
    ["SYMBOLGEN: X resolves to _ERROR_=1\n", 0, 0, 'SYMBOLGEN error text excluded'],
    ["NOTE: There were 10 observations read.\n", 0, 0, 'routine observation note excluded'],
    ["before\n=== SAS Log ===\nWARNING: inside\n=== Output ===\nWARNING: after\n", 1, 0, 'wrapper isolates SAS log section'],
    ["WARNING: crlf\r\nNOTE: Invalid data for x.\r\n", 1, 1, 'CRLF diagnostics supported'],
    ["WARNING: A\nWARNING: B\nWARNING: C\nWARNING: D\n", 4, 0, 'distinct warnings retained'],
    ["NOTE: Invalid data for x.\nNOTE: Invalid data for x.\n", 0, 1, 'duplicate data diagnostics collapse'],
    ["", 0, 0, 'empty diagnostic input'],
);
for my $case (@diagnostic_cases) {
    my $summary=SAS_Log_Diagnostics::summarize($case->[0]);
    task_deep([$summary->{warning_count},$summary->{data_quality_count}],
        [$case->[1],$case->[2]],$case->[3]);
}

# T076-T100: ownership-marker validation and removal safety.
my $root=tempdir(CLEANUP=>1);
my $resolved_root=abs_path($root);
sub owned_dir {
    my ($name,$marker)=@_;
    my $path="$root/$name";
    make_path($path);
    if (defined $marker) {
        open my $fh,'>',"$path/.mcp4sas-owner.json" or die $!;
        print {$fh} ref($marker) ? encode_json($marker) : $marker;
        close $fh or die $!;
    }
    return $path;
}
sub inspected { my ($path,$base)=@_; my @got=MCP4SAS_Temp::inspect_owned($path,$base//$root); return \@got; }

task_is(scalar @{inspected("$root/missing",$root)},0,'missing candidate rejected');
task_is(scalar @{inspected($root,"$root/missing-root")},0,'missing ownership root rejected');
my $wrong_name=owned_dir('ordinary_dir',{pid=>$$,root=>$resolved_root,created=>time});
task_is(scalar @{inspected($wrong_name)},0,'non-owned basename rejected');
my $hyphen=owned_dir('.mcp4sas_work_bad-name',{pid=>$$,root=>$resolved_root,created=>time});
task_is(scalar @{inspected($hyphen)},0,'hyphenated ownership suffix rejected');
my $no_marker=owned_dir('.mcp4sas_work_nomarker',undef);
task_is(scalar @{inspected($no_marker)},0,'missing marker rejected');
my $bad_json=owned_dir('.mcp4sas_work_badjson','{broken');
task_is(scalar @{inspected($bad_json)},0,'malformed marker JSON rejected');
my $array_json=owned_dir('.mcp4sas_work_array','[]');
task_is(scalar @{inspected($array_json)},0,'non-object marker JSON rejected');
my $wrong_root=owned_dir('.mcp4sas_work_wrongroot',{pid=>$$,root=>'/tmp/not-owner',created=>time});
task_is(scalar @{inspected($wrong_root)},0,'marker with wrong root rejected');
my $no_pid=owned_dir('.mcp4sas_work_nopid',{root=>$resolved_root,created=>time});
task_is(scalar @{inspected($no_pid)},0,'marker without PID rejected');
my $text_pid=owned_dir('.mcp4sas_work_textpid',{pid=>'abc',root=>$resolved_root,created=>time});
task_is(scalar @{inspected($text_pid)},0,'nonnumeric PID rejected');
my $negative_pid=owned_dir('.mcp4sas_work_negpid',{pid=>-2,root=>$resolved_root,created=>time});
task_is(scalar @{inspected($negative_pid)},0,'negative PID rejected');
my $zero_pid=owned_dir('.mcp4sas_work_zeropid',{pid=>0,root=>$resolved_root,created=>time});
task_is(scalar @{inspected($zero_pid)},0,'PID zero rejected');
my $no_created=owned_dir('.mcp4sas_work_nocreated',{pid=>$$,root=>$resolved_root});
task_is(scalar @{inspected($no_created)},0,'marker without creation time rejected');
my $text_created=owned_dir('.mcp4sas_work_textcreated',{pid=>$$,root=>$resolved_root,created=>'today'});
task_is(scalar @{inspected($text_created)},0,'nonnumeric creation time rejected');
my $nested_parent=owned_dir('.mcp4sas_work_parent',{pid=>$$,root=>$resolved_root,created=>time});
my $nested="$nested_parent/.mcp4sas_work_nested"; make_path($nested);
open my $nested_fh,'>',"$nested/.mcp4sas-owner.json" or die $!;
print {$nested_fh} encode_json({pid=>$$,root=>$resolved_root,created=>time}); close $nested_fh;
task_is(scalar @{inspected($nested)},0,'nested owned-looking directory rejected');
my $valid=owned_dir('.mcp4sas_work_valid',{pid=>$$,root=>$resolved_root,created=>time,extra=>'allowed'});
my $valid_info=inspected($valid);
task_is(scalar @$valid_info,2,'valid ownership marker accepted');
task_is($valid_info->[0],abs_path($valid),'valid inspection returns canonical path');
task_is($valid_info->[1]{pid},$$,'valid inspection returns marker PID');
task_is($valid_info->[1]{root},$resolved_root,'valid inspection returns canonical root');
task_is($valid_info->[1]{extra},'allowed','extra marker metadata preserved');
my $remove_error=eval { MCP4SAS_Temp::remove_owned($wrong_name,$root); 1 };
task_ok(!$remove_error && $@ =~ /Cannot verify owned scratch/,'remove refuses unowned directory');
task_ok(-d $wrong_name,'refused removal preserves directory');
my $remove_ok=eval { MCP4SAS_Temp::remove_owned($valid,$root); 1 };
task_ok($remove_ok,'verified owned directory removal succeeds');
task_ok(!-e $valid,'verified removal deletes directory');
my $link="$root/.mcp4sas_work_link";
my $link_created=symlink($wrong_name,$link);
task_ok(!$link_created || scalar(@{inspected($link)})==0,'symlink candidate rejected');

die "Internal task numbering error: generated $task tasks instead of 100\n" unless $task == 100;
