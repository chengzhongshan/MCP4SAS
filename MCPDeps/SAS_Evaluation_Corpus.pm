package SAS_Evaluation_Corpus;
use strict; use warnings;
use Digest::SHA qw(sha256_hex);
use JSON::PP ();
sub contract_fingerprint {
    my ($case)=@_;
    # Executable hashes alone do not capture a changed oracle or error matcher.
    my $contract={
        expected_failure=>$case->{expected_failure}?1:0,
        expected=>$case->{expected},diagnostic=>$case->{diagnostic}//'',
        tolerance=>$case->{tolerance}//'1e-9'};
    $contract->{warning_pattern}=$case->{warning_pattern} if length($case->{warning_pattern}//'');
    $contract->{policy_failure}=1 if $case->{policy_failure};
    return sha256_hex(JSON::PP->new->canonical->encode($contract));
}
sub checked_contract {
    my ($case,$recorded)=@_;
    return 0 unless defined $recorded; # Explicitly identify legacy evidence.
    die "Evaluation contract mismatch $case->{id}; rerun against the reviewed manifest"
        unless $recorded eq contract_fingerprint($case);
    return 1;
}
sub select_cases {
    my ($manifest,$only)=@_;
    die 'Invalid corpus manifest' unless ref($manifest) eq 'HASH' && ref($manifest->{cases}) eq 'ARRAY'
        && ($manifest->{count}//'')=~/^\d+$/ && $manifest->{count}>0 && @{$manifest->{cases}}==$manifest->{count};
    my %known;
    for my $case (@{$manifest->{cases}}) {
        die 'Invalid case metadata' unless ref($case) eq 'HASH' && ($case->{id}//'')=~/^[A-Z]\d{3,4}$/
            && ($case->{file}//'') eq "$case->{id}.sas" && ($case->{body_sha256}//'')=~/^[a-f0-9]{64}$/i;
        die "Duplicate manifest ID $case->{id}" if $known{$case->{id}}++;
        die "Missing expected-error diagnostic $case->{id}" if $case->{expected_failure} && !length($case->{diagnostic}//'');
        die "Missing numerical oracle $case->{id}" if !$case->{expected_failure} && !defined($case->{expected});
    }
    return [@{$manifest->{cases}}] unless defined($only) && length($only);
    my %selected;
    for my $id (split /,/,$only,-1) {
        $id=~s/^\s+|\s+$//g;
        die 'Empty selected ID' unless length $id;
        die "Duplicate selected ID $id" if $selected{$id}++;
        die "Unknown selected ID $id" unless $known{$id};
    }
    return [grep {$selected{$_->{id}}} @{$manifest->{cases}}];
}
sub checked_source {
    my ($case,$source)=@_;
    die "Missing program $case->{id}" unless defined($source) && length($source);
    my $canonical=$source; $canonical=~s/\r\n?/\n/g;
    $canonical=~s{\A/\*[^\n]*\*/\n}{};
    my $letter=substr($case->{id},0,1);
    if ($letter eq 'L') {$canonical=~s/L\d{3}/LCASE/g;}
    elsif ($letter eq 'R') {$canonical=~s/r\d{3,4}/rCASE/ig;}
    else {$canonical=~s/\Q$letter\E\d{4}/lc($letter).'CASE'/ige;}
    die "Program body hash mismatch $case->{id}; rebuild/review the manifest before executing changed fixtures"
        unless sha256_hex($canonical) eq lc($case->{body_sha256});
    return $source;
}
sub behavior_fingerprint {
    my ($case,$source)=@_;
    checked_source($case,$source);
    $source=~s/\r\n?/\n/g;
    $source=~s{\A/\*[^\n]*\*/\n}{};
    # Ignore generated case/round labels when comparing different corpora.
    # Keep inputs, operators and oracles: changing a label is not a new test.
    $source=~s/\Q$case->{id}\E/CASE/ig;
    $source=~s/\b(?:LIB500|ROUND\d+)_(PASS|FAIL|ROWS)=/EVAL_$1=/g;
    return sha256_hex($source);
}
1;
