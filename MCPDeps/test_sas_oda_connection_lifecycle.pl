#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);
use File::Spec;

my $runner_path = File::Spec->catfile($Bin, 'SAS_ODA_Runner.pm');
open my $fh, '<', $runner_path or die "Cannot read $runner_path: $!\n";
local $/;
my $runner = <$fh>;
close $fh or die "Cannot close $runner_path: $!\n";

die "Missing structured MCP4SAS connection lifecycle output\n"
    unless $runner =~ /MCP4SAS SAS connection lifecycle:/
        && $runner =~ /subprocess id:/
        && $runner =~ /closure reason:/
        && $runner =~ /next step:/;

my $close_calls = () = $runner =~ /_print_one_shot_connection_close\(session_obj, action, result, next_step\)/g;
die "Expected lifecycle output in both one-shot cleanup paths\n" unless $close_calls == 2;

die "Macro helper upload does not explain the expected follow-up connection\n"
    unless $runner =~ /connection_purpose => 'macro bootstrap helper upload\/reuse check'/
        && $runner =~ /connection_next_step => 'open a separate one-shot connection for macro bootstrap and SAS code submission'/;

die "Remote helper reuse metadata lookup drops connection lifecycle context\n"
    unless $runner =~ /\$self->fileinfo\(\s*\$remote_path,\s*\{\s*connection_purpose => \$opts->\{connection_purpose\},\s*connection_next_step => \$opts->\{connection_next_step\}/s;

die "One-shot submit cleanup does not identify its action\n"
    unless $runner =~ /SAS code submission \(including macro bootstrap when required\)/;

print "MCP4SAS connection lifecycle diagnostics: PASS\n";
