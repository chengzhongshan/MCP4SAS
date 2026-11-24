use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../MCPDeps";
use Test::More;
use IO::Socket::INET;
use JSON::PP qw(encode_json);

my $listener = IO::Socket::INET->new(LocalAddr => '127.0.0.1', LocalPort => 0,
    Proto => 'tcp', Listen => 2, ReuseAddr => 1) or die $!;
$ENV{SAS_ODA_SESSION_PORT} = $listener->sockport;
require SAS_ODA_Runner;

{
    no warnings 'redefine';
    local *IO::Socket::INET::new = sub {
        socket(my $sock, Socket::AF_INET(), Socket::SOCK_STREAM(), 0) or die $!;
        return bless $sock, 'IO::Socket::INET';
    };
    ok(!SAS_ODA_Runner::_server_reachable('127.0.0.1', $listener->sockport),
        'unconnected socket object is not a reachable server');
    my $result = eval { SAS_ODA_Runner::_call_session_server({cmd => 'ping'}, 2) };
    is($@, '', 'unconnected socket does not throw a peer-address exception');
    is($result->{error}, 'cannot connect to session server', 'returns structured connect failure');
    ok(SAS_ODA_Runner::_session_server_error_is_transport($result), 'failure permits transport recovery');
}

my $pid = fork();
die $! unless defined $pid;
if (!$pid) {
    my $sock = $listener->accept() or die $!;
    my $header = '';
    read($sock, $header, 8) == 8 or die 'missing request header';
    my $length = unpack('Q>', $header);
    my $body = '';
    while (length($body) < $length) {
        my $count = read($sock, my $part, $length - length($body));
        die 'missing request body' unless $count;
        $body .= $part;
    }
    my $json = encode_json({status => 'ok', received => JSON::PP::decode_json($body)->{cmd}});
    print {$sock} pack('Q>', length($json)), $json;
    close $sock;
    exit 0;
}
my $result = SAS_ODA_Runner::_call_session_server({cmd => 'ping'}, 2);
is($result->{status}, 'ok', 'connected TCP request still succeeds');
is($result->{received}, 'ping', 'length-prefixed payload preserved');
waitpid($pid, 0);
is($?, 0, 'fixture server exits cleanly');
close $listener;
done_testing;
