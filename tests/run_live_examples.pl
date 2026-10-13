#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);
use Cwd qw(abs_path);
use File::Temp qw(tempdir);
use File::Path qw(make_path);
use JSON::PP qw(decode_json);
use Test::More;

die "Usage: perl tests/run_live_examples.pl --live\nUses your configured SAS ODA account and the public GTEx API.\n"
    unless @ARGV == 1 && $ARGV[0] eq '--live';
my $root = abs_path("$Bin/..");
chdir $root or die $!;
my $output = tempdir('SAS_Output_examples_XXXXXX', DIR => $root, CLEANUP => 0);
local $ENV{OPEN_RESULT} = 0;
local $ENV{SAS_ODA_AUTOLOAD_MACROS} = 0;
sub read_file {
    open my $fh, '<', $_[0] or die "$_[0]: $!";
    local $/;
    return <$fh>;
}
for my $case (qw(basic_summary macro_control_flow expected_missing_table gtex_eqtl)) {
    my $dir = "$output/$case";
    make_path($dir);
    my $pid = fork();
    die "fork: $!" unless defined $pid;
    if (!$pid) {
        open STDOUT, '>', "$dir/runner.log" or die $!;
        open STDERR, '>&STDOUT' or die $!;
        exec $^X, "$root/run_sas_codes_or_files_in_ODA.pl",
            '--file', "examples/$case.sas", '--output-prefix', "$dir/result",
            '--run-timeout-seconds', '180';
        die "exec: $!";
    }
    waitpid($pid, 0);
    my $exit = $? >> 8;
    my $expected_failure = $case eq 'expected_missing_table';
    is($exit, $expected_failure ? 1 : 0, "$case exit status");
    my $status_file = "$dir/result/output.run.status.json";
    ok(-f $status_file, "$case writes status JSON");
    next unless -f $status_file;
    my $status = decode_json(read_file($status_file));
    is($status->{success}, $expected_failure ? 0 : 1, "$case machine-readable success");
    my $log = read_file("$dir/result/output.html.info.txt");
    unlike($log, qr/Injected targeted remote macro loader/, "$case is self-contained");
    if ($expected_failure) {
        like($log, qr/ERROR: File WORK\.MCP4SAS_MISSING_TABLE\.DATA does not exist/i,
             'genuine SAS failure retained in log');
    } else {
        my @html = glob("$dir/result/sas_res_*.html");
        ok(@html && -s $html[0], "$case produces HTML");
        if ($case eq 'gtex_eqtl' && @html) {
            like(read_file($html[0]), qr/APOBEC3A/, 'GTEx records rendered');
        }
    }
}
diag("Live artifacts: $output");
done_testing();
