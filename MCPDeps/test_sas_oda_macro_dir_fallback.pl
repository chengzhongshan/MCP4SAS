#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib $Bin;
use File::Spec;
use File::Temp qw(tempdir);
use Cwd qw(abs_path getcwd);
use SAS_ODA_Runner;
use Test::More;

my $original = getcwd();
my $workspace = tempdir(CLEANUP => 1);
chdir $workspace or die "Cannot enter $workspace: $!";
my $macro = File::Spec->catfile($workspace, 'current_macro.sas');
open my $fh, '>', $macro or die "Cannot create $macro: $!";
print {$fh} "%macro current_macro; %mend;\n";
close $fh;

my $missing = File::Spec->catdir($workspace, 'missing-macros');
my ($fallback, $warning) = SAS_ODA_Runner::normalize_local_macro_dir($missing);
is(abs_path($fallback), abs_path($workspace), 'unreachable macro directory falls back to process working directory');
like($warning, qr/using the current working directory/, 'fallback is explained to the caller');

my $runner = SAS_ODA_Runner->new(local_macro_dir => $missing);
is(abs_path($runner->{local_macro_dir}), abs_path($workspace), 'runner stores the fallback macro directory');
is(abs_path($runner->_find_local_macro_file('current_macro')), abs_path($macro), 'macro discovery uses the fallback directory');
my (undef, $dependency_log) = $runner->_process_dependencies('data _null_; run;');
like($dependency_log, qr/using the current working directory/, 'fallback warning is included in dependency logs');

chdir $original or die "Cannot restore $original: $!";
done_testing();
