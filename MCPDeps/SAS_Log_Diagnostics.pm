package SAS_Log_Diagnostics;
use strict;
use warnings;

# Preserve SAS severity: a data-quality NOTE or WARNING is not a fatal error.
# The existing worker exit status remains the authority for MCP success.
sub summarize {
    my ($text) = @_;
    $text //= '';
    # Worker logs also contain source and preflight reports. Only classify the
    # actual SAS log section when one exists; raw SAS logs remain supported.
    if ($text =~ /=== SAS Log ===\r?\n(.*?)(?:\r?\n=== Output ===|\z)/s) {
        $text = $1;
    }
    my %seen;
    my $result = {warnings => [], data_quality => []};
    for my $line (split /\r?\n/, $text) {
        $line =~ s/^\s+|\s+$//g;
        my $kind;
        if ($line =~ /^WARNING(?:\s+\d+-\d+)?:/i) {
            $kind = 'warnings';
        } elsif ($line =~ /^NOTE:\s+(?:Invalid (?:data|argument)|Division by zero|Mathematical operations could not be performed|Missing values were generated|(?:Character|Numeric) values have been converted)/i
            || $line =~ /^(?!\d+\s|MPRINT\b|SYMBOLGEN\b|NOTE:).*\b_ERROR_=1\b/) {
            $kind = 'data_quality';
        }
        next unless $kind;
        next if $seen{"$kind\0$line"}++;
        push @{$result->{$kind}}, $line;
    }
    $result->{warning_count} = scalar @{$result->{warnings}};
    $result->{data_quality_count} = scalar @{$result->{data_quality}};
    return $result;
}

sub format_summary {
    my ($result) = @_;
    return '' unless $result->{warning_count} || $result->{data_quality_count};
    my $text = "SAS diagnostics: $result->{warning_count} warning(s), "
        . "$result->{data_quality_count} data-quality diagnostic(s).\n";
    for my $kind (qw(warnings data_quality)) {
        my @lines = @{$result->{$kind}};
        splice @lines, 3 if @lines > 3;
        $text .= join('', map { "  $_\n" } @lines);
    }
    return $text . "\n";
}

1;
