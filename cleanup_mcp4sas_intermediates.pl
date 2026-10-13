#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/MCPDeps";
use Cwd qw(abs_path getcwd);
use Getopt::Long qw(GetOptions);
use File::Spec;
use MCP4SAS_Temp;

my ($apply, $directory, $hours) = (0, getcwd(), 24);
GetOptions('apply' => \$apply, 'directory=s' => \$directory, 'older-than-hours=f' => \$hours)
    or die "Usage: perl cleanup_mcp4sas_intermediates.pl [--apply] [--directory PATH] [--older-than-hours 24]\n";
die "Age must be nonnegative\n" if $hours < 0;
my $root = abs_path($directory) or die "Directory does not exist: $directory\n";
opendir my $dh, $root or die $!;
my @names = grep { /^\.mcp4sas_work_[A-Za-z0-9_]+$/ } readdir $dh;
closedir $dh;
my $count = 0;
for my $name (sort @names) {
    my ($path, $info) = MCP4SAS_Temp::inspect_owned(File::Spec->catdir($root, $name), $root);
    next unless $path;
    next if time - $info->{created} < $hours * 3600;
    # A live PID or a permission-denied probe both mean the directory is in use.
    local $! = 0;
    next if kill(0, $info->{pid}) || $!{EPERM};
    print(($apply ? 'Removing' : 'Would remove') . ": $path\n");
    MCP4SAS_Temp::remove_owned($path, $root) if $apply;
    ++$count;
}
print "Eligible owned scratch directories: $count\n";
print "Preview only; use --apply to remove them.\n" unless $apply;
