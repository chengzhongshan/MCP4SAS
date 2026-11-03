package SAS_Log_Diagnostics;
use strict;
use warnings;
sub _macro_diagnostic {
    my ($line)=@_;
    return unless $line=~/^(?:ERROR|WARNING)(?:\s+\d+-\d+)?:/i;
    my ($kind,$hint);
    if ($line=~/open code statement recursion/i) {
        ($kind,$hint)=('open_code_recursion','Check for a missing semicolon before the next %LET/%PUT or other macro statement.');
    } elsif ($line=~/not valid in open code|nesting of.*%IF.*open code|%DO.*required|Expected %DO not found/i) {
        ($kind,$hint)=('open_code_control','Use a macro wrapper for loops, %LOCAL and nested conditionals; open-code %IF requires supported %THEN/%ELSE %DO groups.');
    } elsif ($line=~/apparent symbolic reference.*not resolved/i) {
        ($kind,$hint)=('unresolved_macro_variable','Check spelling, scope, creation timing and the dot delimiter before appended text.');
    } elsif ($line=~/apparent invocation of macro.*not resolved/i) {
        ($kind,$hint)=('unresolved_macro_invocation','Define or load the macro before invoking it; verify its source filename and macro name.');
    } elsif ($line=~/recursive reference.*(?:macro|text expression)|text expression.*recursive reference/i) {
        ($kind,$hint)=('recursive_macro_reference','Avoid a parameter or variable default that resolves to itself.');
    } elsif ($line=~/(?:macro variable|macro definition|macro .*?)(?:.*)(?:not found|does not exist|could not be deleted)/i) {
        ($kind,$hint)=('missing_macro_symbol','Check %SYMEXIST/%SYSMACEXIST or use the deletion statement NOWARN option for intentional no-ops.');
    } elsif ($line=~/%(?:EVAL|SYSEVALF|SYSFUNC|SUBSTR|SCAN)\b|(?:positional|keyword|duplicate).*parameter/i) {
        ($kind,$hint)=('macro_expression','Check macro argument order/quoting and integer operands; use %SYSEVALF for decimal arithmetic.');
    }
    return unless $kind;
    return {kind=>$kind,message=>$line,hint=>$hint,severity=>$line=~/^ERROR/i?'error':'warning'};
}

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
    my $result = {warnings => [], data_quality => [], macro_diagnostics => []};
    for my $line (split /\r?\n/, $text) {
        $line =~ s/^\s+|\s+$//g;
        if (my $macro=_macro_diagnostic($line)) {
            push @{$result->{macro_diagnostics}},$macro unless $seen{"macro\0$line"}++;
        }
        my $kind;
        if ($line =~ /^WARNING(?:\s+\d+-\d+)?:/i) {
            $kind = 'warnings';
        } elsif ($line =~ /^NOTE:\s+(?:Invalid (?:data|argument)|Variable .+ is uninitialized\.|Division by zero|Mathematical operations could not be performed|Missing values were generated|(?:Character|Numeric) values have been converted|SAS went to a new line when INPUT statement reached past the end of a line|No observations in data set)/i
            || $line =~ /^(?!\d+\s|MPRINT\b|SYMBOLGEN\b|NOTE:).*\b_ERROR_=1\b/) {
            $kind = 'data_quality';
        }
        next unless $kind;
        next if $seen{"$kind\0$line"}++;
        push @{$result->{$kind}}, $line;
    }
    $result->{warning_count} = scalar @{$result->{warnings}};
    $result->{data_quality_count} = scalar @{$result->{data_quality}};
    $result->{macro_count} = scalar @{$result->{macro_diagnostics}};
    return $result;
}

sub format_summary {
    my ($result) = @_;
    return '' unless $result->{warning_count} || $result->{data_quality_count} || $result->{macro_count};
    my $text = "SAS diagnostics: $result->{warning_count} warning(s), "
        . "$result->{data_quality_count} data-quality diagnostic(s).\n";
    for my $kind (qw(warnings data_quality)) {
        my @lines = @{$result->{$kind}};
        splice @lines, 3 if @lines > 3;
        $text .= join('', map { "  $_\n" } @lines);
    }
    if ($result->{macro_count}) {
        $text.="Macro diagnostics: $result->{macro_count}.\n";
        my @macros=@{$result->{macro_diagnostics}}; splice @macros,3 if @macros>3;
        $text.=join('',map {"  $_->{message}\n  Hint: $_->{hint}\n"} @macros);
    }
    return $text . "\n";
}

1;
