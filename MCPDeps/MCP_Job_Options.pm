package MCP_Job_Options;
use strict;
use warnings;
use Time::HiRes ();

# Waiting changes result delivery, never the SAS execution timeout or program.
sub wait_seconds {
    my ($value) = @_;
    $value = 20 unless defined $value;
    die "wait_seconds must be a number between 0 and 30\n"
      if ref($value) || $value !~ /\A(?:\d+(?:\.\d*)?|\.\d+)\z/
        || $value < 0 || $value > 30;
    return 0 + $value;
}

sub log_limit {
    my ($value) = @_;
    $value = 16000 unless defined $value;
    die "max_log_chars must be an integer between 0 and 1000000\n"
      if ref($value) || $value !~ /\A\d+\z/ || $value > 1000000;
    return 0 + $value;
}

sub _now {
    # Some native Windows Perls expose Time::HiRes without clock_gettime.
    my $value = eval { Time::HiRes::clock_gettime(Time::HiRes::CLOCK_MONOTONIC()) };
    return defined($value) ? $value : Time::HiRes::time();
}

sub await_completion {
    my ($ready, $seconds) = @_;
    my $deadline = _now() + $seconds;
    while (!$ready->()) {
        my $left = $deadline - _now();
        return 0 if $left <= 0;
        Time::HiRes::sleep($left < 0.1 ? $left : 0.1);
    }
    return 1;
}

sub log_excerpt {
    my ($text, $limit, $path) = @_;
    $text //= '';
    return $text unless $limit && length($text) > $limit;
    my $head = int($limit / 4);
    return substr($text, 0, $head)
      . "\n[Middle output omitted; complete log: $path]\n"
      . substr($text, -($limit - $head));
}

1;
