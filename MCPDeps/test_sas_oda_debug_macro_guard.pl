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
    my $import = '%importallmacros_ue(MacroDir=&_macro_home,fileRgx=.,verbose=0);';
    my $include = '%include';

    my $probe_at = index($block, $probe);
    my $import_at = index($block, $import);
    my $include_at = index($block, $include);
    die "Block $block_number lacks the debug_macro %sysmacexist probe\n" if $probe_at < 0;
    die "Block $block_number still treats debug_macro as proof that all macros were loaded\n"
        if index($block, $guard) >= 0;
    die "Block $block_number can still mark the all-macro import as skipped\n"
        if $block =~ /%let\s+_pipeline_macro_boot_skipped\s*=\s*1\s*;/i;
    die "Block $block_number lacks the fallback macro include\n" if $include_at < 0;
    die "Block $block_number lacks the all-macro import call\n" if $import_at < 0;
    die "Block $block_number probes debug_macro after macro-library inclusion\n"
        unless $probe_at < $include_at;
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

die "Embedded server caches a failed macro bootstrap as loaded\n"
    unless $runner =~ /session_macros_loaded\[session_id\]\s*=\s*bootstrap_ok\s*==\s*'1'/;
die "Standalone server caches a failed macro bootstrap as loaded\n"
    unless $server =~ /session_macros_loaded\[session_id\]\s*=\s*bootstrap_ok\s*==\s*'1'/;
die "One-shot session caches a failed macro bootstrap as loaded\n"
    unless $runner =~ /session_obj\._macros_loaded\s*=\s*bootstrap_ok\s*==\s*'1'/;
die "Requested macros are not conditionally restored after the all-macro import\n"
    unless $runner =~ /%if not %sysmacexist\(\$name\) %then %include/;
die "Del_Dir_Recursive lacks its supplemental post-bootstrap loader\n"
    unless $runner =~ /my \@explicit_remote = grep \{lc\(\$_\) eq 'del_dir_recursive'\}/;
die "Targeted macro verification still runs inside the include wrapper\n"
    unless $runner =~ /%_pipeline_load_macro_tmp;\s*%macro _pipeline_verify_macro_tmp;/;

print "SAS ODA macro bootstrap sentinel regression: PASS\n";
