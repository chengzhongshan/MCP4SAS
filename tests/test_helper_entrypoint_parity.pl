#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);
use File::Spec;
use Test::More tests => 1;

my $root = File::Spec->catdir($Bin, '..');
my $script_helper = File::Spec->catfile($root, 'run_sas_codes_or_script_in_ODA.pl');
my $files_helper = File::Spec->catfile($root, 'run_sas_codes_or_files_in_ODA.pl');

open my $script_fh, '<', $script_helper or die "Cannot read $script_helper: $!\n";
open my $files_fh, '<', $files_helper or die "Cannot read $files_helper: $!\n";
local $/;
my $script_source = <$script_fh>;
my $files_source = <$files_fh>;

is(
    $script_source,
    $files_source,
    'compatibility helper entry points remain byte-identical',
);
