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

die "Missing structured SAS connection lifecycle output\n"
    unless $runner =~ /Pipeline SAS connection lifecycle:/
        && $runner =~ /subprocess id:/
        && $runner =~ /closure reason:/
        && $runner =~ /shutdown outcome:/
        && $runner =~ /SAS log:/
        && $runner =~ /next step:/;

my $handoffs = () = $runner =~ /payload\['connection_lifecycle'\]\s*=/g;
die "Expected one-shot SAS submission and file-action lifecycle handoffs\n" unless $handoffs == 2;
my $parent_reports = () = $runner =~ /_report_one_shot_connection_lifecycle\(\$result,/g;
die "Expected both lifecycle handoffs to be reported by the parent Perl process\n"
    unless $parent_reports == 2;

die "Macro helper upload does not explain the expected follow-up connection\n"
    unless $runner =~ /connection_purpose => 'macro bootstrap helper upload\/reuse check'/
        && $runner =~ /connection_next_step => 'open a separate one-shot connection for macro bootstrap and SAS code submission'/;

die "Remote helper reuse metadata lookup drops connection lifecycle context\n"
    unless $runner =~ /\$self->fileinfo\(\s*\$remote_path,\s*\{\s*connection_purpose => \$opts->\{connection_purpose\},\s*connection_next_step => \$opts->\{connection_next_step\}/s;

die "One-shot submit cleanup does not identify its action\n"
    unless $runner =~ /SAS code submission \(including macro bootstrap when required\)/
        && $runner =~ /intentionally called SASPy endsas\(\) after capturing the one-shot SAS submit response/
        && $runner =~ /sas_log_summary/
        && $runner =~ /SAS submit returned with \{log_errors\} ERROR line/;

print "SAS ODA connection lifecycle diagnostics: PASS\n";
