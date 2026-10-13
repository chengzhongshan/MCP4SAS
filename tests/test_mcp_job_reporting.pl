#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../MCPDeps";
use SAS_Log_Diagnostics;
use Cwd qw(abs_path getcwd);
use File::Temp qw(tempdir);
use File::Path qw(remove_tree);
use File::Copy qw(copy);
use File::Spec;
use File::Basename qw(basename dirname);
use JSON::PP qw(encode_json decode_json);
use Test::More;

open my $fh, '<', "$Bin/../server.pl" or die $!;
my $source = do { local $/; <$fh> };
close $fh;
my ($function) = $source =~ /^(sub run_sas_oda_tool \{.*?^\})/ms;
die 'Missing MCP callback' unless $function;
eval $function;
die $@ if $@;
my ($direct_function) = $source =~ /^(sub run_local_direct_sas_tool \{.*?^\})/ms;
die 'Missing direct local SAS callback' unless $direct_function;
eval $direct_function;
die $@ if $@;
my ($cleanup_function) = $source =~ /^(sub cleanup_worker_scratch \{.*?^\})/ms;
die 'Missing worker scratch cleanup helper' unless $cleanup_function;
eval $cleanup_function;
die $@ if $@;
my ($create_directories_function) = $source =~ /^(sub create_job_directories \{.*?^\})/ms;
die 'Missing job-directory helper' unless $create_directories_function;
eval $create_directories_function;
die $@ if $@;
open my $runner_fh, '<', "$Bin/../MCPDeps/SAS_ODA_Runner.pm" or die $!;
my $runner_source = do { local $/; <$runner_fh> };
close $runner_fh;
my ($runner_temp_function) = $runner_source =~ /^(sub _runner_temp_dir \{.*?^\})/ms;
die 'Missing runner temporary-directory helper' unless $runner_temp_function;
eval $runner_temp_function;
die $@ if $@;

my $original_cwd = getcwd();
my $test_workdir = tempdir('mcp_reporting_test_XXXXXX', TMPDIR => 1, CLEANUP => 1);
chdir $test_workdir or die $!;
END { chdir $original_cwd if defined $original_cwd; }
# Inspect scratch only in this test's workspace; concurrent live jobs own
# independent directories and must not affect the cleanup assertion.
my $scratch = tempdir('tmpMCP4SAS_test_XXXXXX', DIR => File::Spec->rel2abs('.'), CLEANUP => 0);
open my $scratch_file, '>', "$scratch/input.sas" or die $!;
print {$scratch_file} 'proc means;';
close $scratch_file;
is(cleanup_worker_scratch($scratch), '', 'worker scratch cleanup succeeds');
ok(!-e $scratch, 'worker scratch directory is removed');
my $runner_scratch = tempdir('tmpMCP4SAS_runner_XXXXXX', DIR => File::Spec->rel2abs('.'), CLEANUP => 0);
{
    local $ENV{MCP4SAS_WORKER_TEMP_DIR} = $runner_scratch;
    is(_runner_temp_dir(), abs_path($runner_scratch), 'SASPy helper temp files use MCP worker scratch');
}
{
    local $ENV{MCP4SAS_WORKER_TEMP_DIR} = "$runner_scratch/missing";
    is(_runner_temp_dir(), getcwd(), 'invalid worker temp path falls back to current directory');
}
my $runner_scratch_errors;
remove_tree($runner_scratch, { error => \$runner_scratch_errors });
ok(!-e $runner_scratch, 'test removes runner scratch fixture');

my $dir = tempdir(CLEANUP => 1);
my $pid_file = "$dir/output.html.info.pid";
my $direct_out_file = "$dir/output.local_sas_direct.txt";
sub find_status_for_pid { return ($pid_file, "$dir/output.html.info.txt") }
sub find_local_direct_sas_status_for_pid { return ($pid_file, $direct_out_file) }
sub reap_child_if_finished { return 1 }
sub pid_is_running { return 0 }
sub is_truthy { return defined($_[0]) && $_[0] =~ /^(?:1|true|yes|y|on)$/i }
sub is_falsey { return defined($_[0]) && $_[0] =~ /^(?:0|false|no|n|off)$/i }
sub as_list {
    return () unless defined $_[0];
    return @{$_[0]} if ref($_[0]) eq 'ARRAY';
    return ($_[0]);
}
sub runner_path { return File::Spec->catfile($Bin, '..', 'run_sas_codes_or_files_in_ODA.pl') }
sub write_pid_file {
    open my $f, '>', $_[0] or die $!;
    print {$f} $_[1];
    close $f;
}
sub text_result { return {content => [{type => 'text', text => $_[0]}]} }
sub read_text_file {
    open my $f, '<', $_[0] or return '';
    local $/;
    return <$f>;
}
sub write_text_file {
    open my $f, '>', $_[0] or die $!;
    print {$f} $_[1];
    close $f;
}
write_text_file("$dir/custom.txt", 'Full SAS log');
write_text_file("$dir/runner.stdout.txt", 'Worker diagnostics');
for my $code (0, 1, 73, 74, 127, 143) {
    write_text_file($pid_file, 123);
    write_text_file("$dir/worker.result.json", encode_json({
        exit_code => $code, log_path => "$dir/custom.txt",
    }));
    my $result = run_sas_oda_tool({pid => 123});
    is(!!$result->{isError}, !!$code, "exit $code sets MCP error flag");
    like($result->{content}[0]{text}, qr/Exit code: $code\b/, 'exit code retained');
    like($result->{content}[0]{text}, qr/Full SAS log/, 'custom log returned');
}
ok(-f "$dir/custom.txt", 'polling preserves the SAS log');
ok(!-f $pid_file, 'polling removes the completed PID marker');
write_text_file("$dir/custom.txt", "=== SAS Log ===\nNOTE: Division by zero detected at line 3 column 5.\n=== Output ===\n");
write_text_file($pid_file, 123);
write_text_file("$dir/worker.result.json", encode_json({exit_code => 0, log_path => "$dir/custom.txt"}));
my $quality_success = run_sas_oda_tool({pid => 123});
ok(!$quality_success->{isError}, 'data-quality NOTE preserves successful exit status');
is($quality_success->{structuredContent}{status}, 'COMPLETE', 'structured status matches text');
is($quality_success->{structuredContent}{diagnostics}{data_quality_count}, 1, 'structured response includes runtime data-quality NOTE');
like($quality_success->{content}[0]{text}, qr/SAS diagnostics: 0 warning\(s\), 1 data-quality/, 'successful poll surfaces data-quality summary');
unlink "$dir/worker.result.json";
write_text_file($pid_file, 123);
my $unknown = run_sas_oda_tool({pid => 123});
ok($unknown->{isError}, 'missing completion cannot report success');
like($unknown->{content}[0]{text}, qr/STATUS: UNKNOWN/, 'interrupted worker is explicit');
like($unknown->{content}[0]{text}, qr/Worker diagnostics/, 'stdout fallback available');

my $direct_completion_file = "$dir/worker.local_sas.result.json";
write_text_file($direct_out_file, 'Local SAS output');
write_pid_file($pid_file, 456);
write_text_file($direct_completion_file, encode_json({exit_code => 0, cleanup_error => ''}));
my $direct_success = run_local_direct_sas_tool({pid => 456});
like($direct_success->{content}[0]{text}, qr/STATUS: COMPLETE/, 'direct SAS exit 0 reports complete');
ok(!$direct_success->{isError}, 'direct SAS success is not an MCP error');
ok(-f $direct_out_file, 'direct SAS polling preserves output');
ok(!-f $pid_file && !-f $direct_completion_file, 'direct SAS polling removes completion markers');

write_pid_file($pid_file, 457);
write_text_file($direct_completion_file, encode_json({exit_code => 1, cleanup_error => ''}));
my $direct_failure = run_local_direct_sas_tool({pid => 457});
like($direct_failure->{content}[0]{text}, qr/STATUS: FAILED/, 'direct SAS nonzero exit reports failure');
ok($direct_failure->{isError}, 'direct SAS failure is an MCP error');

my $classify_log = "$dir/classify.log";
write_text_file($classify_log, 'NOTE: offline MCP cleanup test');
my %scratch_before = map { $_ => 1 } glob(File::Spec->catfile(getcwd(), 'tmp*'));
my $started = run_sas_oda_tool({classify_sas_log => $classify_log});
my $started_text = $started->{content}[0]{text};
like($started_text, qr/Worker scratch is removed automatically/, 'MCP job advertises automatic scratch cleanup');
my ($result_dir) = $started_text =~ /^Results directory: (.+)$/m;
my ($job_pid) = $started_text =~ /^PID: (\d+)$/m;
ok(defined($result_dir) && -d $result_dir, 'MCP job creates a durable results directory');
ok(defined($job_pid), 'MCP job returns a pollable PID');
if (defined($result_dir) && defined($job_pid)) {
    $dir = $result_dir;
    $pid_file = "$result_dir/output.html.info.pid";
    my $completion_file = "$result_dir/worker.result.json";
    for (1 .. 100) {
        last if -f $completion_file;
        select undef, undef, undef, 0.1;
    }
    ok(-f $completion_file, 'MCP worker writes a completion record');
    my $html_file = "$result_dir/sas_res_cleanup_test.html";
    open my $html, '>', $html_file or die $!;
    print {$html} '<html>retained result</html>';
    close $html;
    my $finished = run_sas_oda_tool({pid => $job_pid});
    like($finished->{content}[0]{text}, qr/STATUS: COMPLETE/, 'offline MCP job polls as complete');
    ok(-f "$result_dir/output.html.info.txt", 'MCP job preserves the SAS diagnostic log');
    ok(-f $html_file, 'polling preserves HTML result artifacts');
    ok(!-f $pid_file && !-f $completion_file, 'polling removes temporary completion markers');
}
my @new_scratch = grep { !$scratch_before{$_} } glob(File::Spec->catfile(getcwd(), 'tmp*'));
is_deeply(\@new_scratch, [], 'completed MCP job leaves no new worker scratch directory');
if (defined($result_dir) && -d $result_dir) {
    my $result_errors;
    remove_tree($result_dir, { error => \$result_errors });
    ok(!-e $result_dir, 'test removes its temporary result fixture');
}

done_testing();
