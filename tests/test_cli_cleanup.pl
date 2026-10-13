#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);
use Cwd qw(abs_path);
use File::Temp qw(tempdir);
use JSON::PP qw(encode_json);
use File::Path qw(remove_tree);
use Test::More;
use lib "$Bin/../MCPDeps";
use MCP4SAS_Temp;
my $root = tempdir(CLEANUP => 1);
my $lib = abs_path("$Bin/../MCPDeps");
my $helper = abs_path("$Bin/../cleanup_mcp4sas_intermediates.pl");
my $child = "$root/child.pl";
open my $fh, '>', $child or die $!;
print {$fh} <<'CHILD';
use strict;
use warnings;
use MCP4SAS_Temp;
chdir $ARGV[0] or die $!;
my $path = MCP4SAS_Temp::initialize(keep => $ARGV[1]);
open my $fh, '>', "$path/helper.json" or die $!;
print {$fh} '{}'; close $fh;
$| = 1; print "$path\n";
my $pid = fork(); die $! unless defined $pid;
if (!$pid) { exit 0 }
waitpid($pid, 0);
die "child removed parent scratch" unless -d $path;
die "intentional test failure\n" if $ARGV[2];
CHILD
close $fh;
for my $failure (0, 1) {
    local $ENV{MCP4SAS_WORKER_TEMP_DIR};
    delete $ENV{MCP4SAS_WORKER_TEMP_DIR};
    open my $pipe, '-|', $^X, '-I', $lib, $child, $root, 0, $failure or die $!;
    my $path = <$pipe>; chomp $path;
    close $pipe;
    is($? >> 8, $failure ? 255 : 0, 'expected child exit');
    ok(!-d $path, 'owned scratch removed after success or exception');
}
my $retained;
{
    local $ENV{MCP4SAS_WORKER_TEMP_DIR}; delete $ENV{MCP4SAS_WORKER_TEMP_DIR};
    open my $pipe, '-|', $^X, '-I', $lib, $child, $root, 1, 0 or die $!;
    $retained = <$pipe>; chomp $retained; close $pipe;
    ok(-f "$retained/helper.json", 'debug retention preserves helper files');
}
open my $marker, '>', "$retained/.mcp4sas-owner.json" or die $!;
print {$marker} encode_json({pid => 2147483647, root => abs_path($root), created => time-90000});
close $marker;
open my $result, '>', "$root/final.html" or die $!; print {$result} 'result'; close $result;
my $unowned = "$root/.mcp4sas_work_unowned"; mkdir $unowned or die $!;
my $active = "$root/.mcp4sas_work_active"; mkdir $active or die $!;
open my $active_marker, '>', "$active/.mcp4sas-owner.json" or die $!;
print {$active_marker} encode_json({pid => $$, root => abs_path($root), created => time-90000});
close $active_marker;
is(system($^X, $helper, '--directory', $root), 0, 'stale cleanup preview runs');
ok(-d $retained, 'preview preserves retained scratch');
is(system($^X, $helper, '--directory', $root, '--apply'), 0, 'stale cleanup applies');
ok(!-d $retained, 'stale owned scratch removed');
ok(-d $unowned, 'unmarked directory preserved');
ok(-d $active, 'active process scratch preserved even when old');
ok(-f "$root/final.html", 'final artifact preserved');
{
    mkdir "$root/caller_owned" or die $!;
    local $ENV{MCP4SAS_WORKER_TEMP_DIR} = "$root/caller_owned";
    open my $pipe, '-|', $^X, '-I', $lib, $child, $root, 0, 0 or die $!;
    my $path = <$pipe>; close $pipe;
    ok(-d "$root/caller_owned", 'caller-owned scratch survives CLI process');
}
pipe my $reader, my $writer or die $!;
my $worker = fork(); die $! unless defined $worker;
if (!$worker) {
    close $reader;
    my $grandchild = fork(); die $! unless defined $grandchild;
    if (!$grandchild) {
        close $writer;
        sleep 3;
        open my $late, '>', "$root/late-write.txt" or die $!;
        print {$late} 'orphan survived'; close $late;
        exit 0;
    }
    print {$writer} "$grandchild\n"; close $writer;
    sleep 20;
    exit 0;
}
close $writer;
my $ready = <$reader>; close $reader;
ok($ready && $ready =~ /^\d+/, 'timeout fixture starts a descendant');
MCP4SAS_Temp::terminate_tree($worker);
waitpid($worker, 0);
sleep 4;
ok(!-f "$root/late-write.txt", 'terminating worker also prevents late descendant writes');
done_testing();
