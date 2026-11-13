#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../MCPDeps";
use SAS_Source_Analysis;
use Getopt::Long qw(GetOptions);
use Digest::SHA qw(sha256_hex);
use JSON::PP;
use Time::HiRes qw(time);

my $repeat = 3;
my $output;
my $help;
GetOptions('repeat=i' => \$repeat, 'output=s' => \$output, 'help' => \$help)
    or die "Use --help for usage\n";
if ($help) {
    print "Usage: perl tools/profile_sas_source.pl [--repeat 3] [--output report.json] program.sas [...]\n";
    print "Measure local source inspection and result hashes without connecting to SAS.\n";
    exit 0;
}
die "Supply at least one SAS source file; use --help for usage\n" unless @ARGV;
die "--repeat must be between 1 and 100\n" unless $repeat >= 1 && $repeat <= 100;

my @operations = (
    ['analyze_source', \&SAS_Source_Analysis::analyze_source],
    ['macro_dependency_view', \&SAS_Source_Analysis::macro_dependency_view],
    ['include_targets', \&SAS_Source_Analysis::include_targets],
);
my $json = JSON::PP->new->canonical;
my @files;
for my $file (@ARGV) {
    open my $fh, '<:raw', $file or die "Cannot read $file: $!\n";
    my $source = do { local $/; <$fh> };
    close $fh;
    my @measurements;
    for my $operation (@operations) {
        my ($name, $function) = @$operation;
        my (@seconds, $result_hash);
        for (1..$repeat) {
            my $start = time;
            my $result = $function->($source);
            push @seconds, time - $start;
            my $encoded = ref($result) ? $json->encode($result) : $result;
            my $hash = sha256_hex($encoded);
            die "Unstable $name result for $file\n" if defined($result_hash) && $hash ne $result_hash;
            $result_hash = $hash;
        }
        my @sorted = sort { $a <=> $b } @seconds;
        my $middle = int(@sorted / 2);
        my $median = @sorted % 2 ? $sorted[$middle] : ($sorted[$middle-1] + $sorted[$middle]) / 2;
        push @measurements, {
            operation => $name,
            seconds => \@seconds,
            median_seconds => $median,
            result_sha256 => $result_hash,
        };
    }
    push @files, {
        file => $file, source_bytes => length($source),
        source_sha256 => sha256_hex($source), measurements => \@measurements,
    };
}
my $report = {
    scope => 'Local Perl source inspection. Timings exclude result hashing, SAS execution, network transfers and model requests.',
    perl_version => "$^V", platform => $^O, repeat => $repeat, files => \@files,
};
my $text = $json->pretty->encode($report);
if (defined $output) {
    open my $out, '>', $output or die "Cannot write $output: $!\n";
    print {$out} $text;
    close $out or die "Cannot close $output: $!\n";
} else {
    print $text;
}
