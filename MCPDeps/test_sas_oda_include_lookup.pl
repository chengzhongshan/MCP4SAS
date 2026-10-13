#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);
use File::Spec;
use File::Temp qw(tempdir);
use File::Path qw(make_path);
use File::Basename qw(basename dirname);
use Cwd qw(abs_path getcwd);
use Test::More;

# Exercise the actual resolver without starting the CLI or a SAS session.
my $original_dir = getcwd();
my $macro_dir = '';
sub find { die "Unexpected recursive search for a bundled macro\n" }
for my $entry (qw(run_sas_codes_or_files_in_ODA.pl run_sas_codes_or_script_in_ODA.pl)) {
    my $path = File::Spec->catfile($Bin, '..', $entry);
    $path = abs_path($path);
    open my $fh, '<', $path or die "Cannot read $path: $!";
    my $source = do { local $/; <$fh> };
    close $fh;
    my ($resolver) = $source =~ /^(sub resolve_local_include_path \{.*?^\})/ms;
    die "Missing include resolver in $entry" unless $resolver;
    {
        no warnings 'redefine';
        eval "#line 1 \"$path\"\n$resolver";
        die $@ if $@;
    }
    my $tmp = tempdir(CLEANUP => 1);
    chdir $tmp or die "Cannot enter $tmp: $!";
    for my $deps (qw(MCPDeps DiffGWASDeps)) {
        make_path($deps);
        my $local = File::Spec->catfile($deps, "$deps-test.sas");
        open my $out, '>', $local or die "Cannot write $local: $!";
        print {$out} "%put TEST;\n";
        close $out;
        is(abs_path(resolve_local_include_path("~/$deps-test.sas")), abs_path($local),
            "$entry resolves $deps macros without recursive traversal");
        is(resolve_local_include_path($local), $local, "$entry preserves explicit local paths");
    }
    is(resolve_local_include_path(''), '', "$entry handles empty include paths");
    chdir $original_dir or die "Cannot restore working directory: $!";
}
done_testing();
