package SAS_Evaluation_Log;
use strict; use warnings;

# Evaluation assertions must come from runtime output, never source listings.
sub evaluate {
    my (%args)=@_;
    my $report=$args{report}//'';
    my $marker=$args{marker}//die 'Missing marker';
    my %expected=map {$_=>1} @{$args{expected}||[]};
    my ($log)=$report=~/^=== SAS Log ===\r?\n(.*?)(?:\r?\n=== Output ===|\z)/ms;
    my $found=defined $log ? 1:0; $log //= '';
    my (%counts,@unexpected,@errors,@warnings);
    for my $line (split /\r?\n/,$log) {
        if ($line =~ /^\Q$marker\E=(\S+)[ \t]*$/) {
            my $id=$1; ++$counts{$id}; push @unexpected,$id unless $expected{$id};
        }
        push @errors,$line if $line=~/^\s*ERROR(?:\s+\d+-\d+)?:/i;
        push @warnings,$line if $line=~/^\s*WARNING(?:\s+\d+-\d+)?:/i;
    }
    my $failure_class=ref($args{status}) eq 'HASH' ? ($args{status}{failure_class}//'') : '';
    my $infrastructure_failure=$failure_class=~/^sas_oda_(?:space_exhaustion|remote_session_termination)$/
        || (defined($args{exit_code}) && ($args{exit_code}==73 || $args{exit_code}==74));
    if (ref($args{status}) eq 'HASH') {
        $infrastructure_failure ||= ($args{status}{state}//'')=~/^(?:timeout|timed_out)$/i
            || $failure_class=~/timeout/i || ($args{status}{message}//'')=~/\btimed\s+out\b/i;
    }
    my ($matched,%passes)=(0);
    if ($args{expected_failure}) {
        die 'Expected-failure evaluation requires one case and a diagnostic pattern'
            unless keys(%expected)==1 && defined($args{diagnostic}) && length($args{diagnostic});
        my $pattern=qr/$args{diagnostic}/i;
        $matched=scalar grep {$_=~$pattern} @errors;
        # The CLI's ordinary SAS program failure is 1. Reserved infrastructure,
        # timeout and signal exits must not validate an intentional SAS error.
        my $valid=$found && defined($args{exit_code}) && $args{exit_code}==1 && !$infrastructure_failure
            && $matched && !keys(%counts);
        %passes=map {$_=>$valid?1:0} keys %expected;
    } else {
        die 'Policy-failure evaluation requires an explicit warning pattern' if $args{policy_failure} && !length($args{warning_pattern}//'');
        my $wanted_exit=$args{policy_failure}?1:0;
        %passes=map {$_=>($found && defined($args{exit_code}) && $args{exit_code}==$wanted_exit && !$infrastructure_failure && !@errors && !@unexpected && ($counts{$_}//0)==1 ? 1:0)} keys %expected;
    }
    my $warning_match=0;
    if (length($args{warning_pattern}//'')) {
        my $pattern=qr/$args{warning_pattern}/i;
        $warning_match=scalar grep {$_=~$pattern} @warnings;
        $passes{$_}=0 for grep {!$warning_match} keys %passes;
    }
    my $status_valid=1;
    if ($args{require_status}) {
        my $status=$args{status};
        $status_valid=ref($status) eq 'HASH' && $status->{complete} && defined($status->{success})
            && (($args{expected_failure} || $args{policy_failure})
                ? (($status->{state}//'') eq 'failed' && !$status->{success})
                : (($status->{state}//'') eq 'completed' && $status->{success}));
        $passes{$_}=0 for grep {!$status_valid} keys %passes;
    }
    return {has_runtime_log=>$found,counts=>\%counts,errors=>\@errors,unexpected=>\@unexpected,passes=>\%passes,
        diagnostic_match=>$matched?1:0,warning_match=>$warning_match?1:0,status_valid=>$status_valid?1:0,infrastructure_failure=>$infrastructure_failure?1:0};
}
1;
