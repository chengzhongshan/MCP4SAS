#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);
use File::Spec;

sub slurp {
    my ($path) = @_;
    open my $fh, '<', $path or die "Cannot read $path: $!\n";
    local $/;
    my $text = <$fh>;
    close $fh or die "Cannot close $path: $!\n";
    return $text;
}

my $runner_path = File::Spec->catfile($Bin, 'SAS_ODA_Runner.pm');
my $server_path = File::Spec->catfile($Bin, 'sas_oda_session_server.py');
my $runner = slurp($runner_path);
my $server = slurp($server_path);
die "Runner still references the overlength SAS macro variable\n"
    if $runner =~ /_pipeline_macro_bootstrap_skipped/;
die "Session server still references the overlength SAS macro variable\n"
    if $server =~ /_pipeline_macro_bootstrap_skipped/;

my @runner_blocks = ($runner =~ /LOAD_MACROS_CODE\s*=\s*'''(.*?)'''/sg);
my @server_blocks = ($server =~ /LOAD_MACROS_CODE\s*=\s*'''(.*?)'''/sg);
die "Expected two embedded LOAD_MACROS_CODE blocks in $runner_path\n"
    unless @runner_blocks == 2;
die "Expected one LOAD_MACROS_CODE block in $server_path\n"
    unless @server_blocks == 1;

my $block_number = 0;
for my $block (@runner_blocks, @server_blocks) {
    ++$block_number;
    my $probe = '%let _pipeline_debug_macro_exists=%sysmacexist(debug_macro);';
    my $guard = '%if &_pipeline_debug_macro_exists %then %do;';
    my $skip = '%let _pipeline_macro_boot_skipped=1;';
    my $include = '%include';

    my $probe_at = index($block, $probe);
    my $guard_at = index($block, $guard);
    my $skip_at = index($block, $skip);
    my $include_at = index($block, $include);
    die "Block $block_number lacks the debug_macro %sysmacexist probe\n" if $probe_at < 0;
    die "Block $block_number lacks the debug_macro bootstrap guard\n" if $guard_at < 0;
    die "Block $block_number lacks the bootstrap-skipped marker\n" if $skip_at < 0;
    die "Block $block_number lacks the fallback macro include\n" if $include_at < 0;
    die "Block $block_number probes debug_macro after macro-library inclusion\n"
        unless $probe_at < $include_at && $guard_at < $include_at && $skip_at < $include_at;
    die "Block $block_number does not expose the skip diagnostic\n"
        unless $block =~ /PIPELINE_MACRO_BOOTSTRAP_SKIPPED=/;
    while ($block =~ /%global\s+([^;]+);/g) {
        for my $name (split /\s+/, $1) {
            next unless length $name;
            die "Block $block_number declares SAS macro variable longer than 32 characters: $name\n"
                if length($name) > 32;
        }
    }
}

my ($perl_api) = $runner =~ /my \$SERVER_API_VERSION = '([^']+)'/;
my @embedded_api = ($runner =~ /^SERVER_API_VERSION = '([^']+)'/mg);
my ($standalone_api) = $server =~ /^SERVER_API_VERSION = '([^']+)'/m;
die "Missing Perl session-server API version\n" unless defined $perl_api;
die "Missing embedded Python session-server API version\n" unless @embedded_api == 1;
die "Missing standalone Python session-server API version\n" unless defined $standalone_api;
die "Session-server API versions are not synchronized\n"
    unless $perl_api eq $embedded_api[0] && $perl_api eq $standalone_api;

for my $required (qw(debug_macro_exists bootstrap_skipped)) {
    die "Runner diagnostics do not expose $required\n" unless $runner =~ /\Q$required\E/;
    die "Session-server diagnostics do not expose $required\n" unless $server =~ /\Q$required\E/;
}

print "SAS ODA debug_macro bootstrap guard: PASS\n";
