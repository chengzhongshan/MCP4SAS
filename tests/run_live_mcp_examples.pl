#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);
use Cwd qw(abs_path);
use File::Temp qw(tempdir);
use File::Path qw(make_path);
use File::Basename qw(basename);
use Getopt::Long qw(GetOptions);
use JSON::PP qw(encode_json);
use Mojo::UserAgent;
use Test::More;

my ($live, $url) = (0, 'http://127.0.0.1:18089/mcp');
GetOptions('live' => \$live, 'url=s' => \$url) or die "Invalid options\n";
die "Usage: perl tests/run_live_mcp_examples.pl --live [--url http://127.0.0.1:18089/mcp]\n"
    unless $live;
my $root = abs_path("$Bin/..");
chdir $root or die $!;
my $out = tempdir('SAS_Output_http_XXXXXX', DIR => $root, CLEANUP => 0);
my $relative = basename($out);
my $token = time . '_' . $$;
my $session = "mcp4sas_test_$token";
my $ua = Mojo::UserAgent->new;
$ua->request_timeout(240);
$ua->inactivity_timeout(240);

sub write_file {
    my ($path, $text) = @_;
    open my $fh, '>:raw', $path or die "$path: $!";
    print {$fh} $text;
    close $fh or die $!;
}
sub read_file {
    open my $fh, '<:raw', $_[0] or die "$_[0]: $!";
    local $/;
    return <$fh>;
}
sub call_tool {
    my ($arguments) = @_;
    my $tx = $ua->post($url => {Connection => 'close'} => json => {
        jsonrpc => '2.0', id => 1, method => 'tools/call',
        params => {name => 'run_sas_codes_or_files_in_ODA', arguments => $arguments},
    });
    my $response = $tx->result;
    die "HTTP failure: " . $response->code unless $response->is_success;
    my $payload = $response->json;
    die encode_json($payload) if !$payload || $payload->{error};
    return $payload->{result};
}
sub job {
    my ($name, $arguments, $failure) = @_;
    $failure ||= 0;
    my $started = call_tool({persistent => JSON::PP::false,
        run_timeout_seconds => 180, %$arguments});
    my $text = $started->{content}[0]{text};
    my ($pid) = $text =~ /PID: (\d+)/;
    my ($directory) = $text =~ /(?:Results|Temporary) directory: ([^\r\n]+)/;
    die "Could not start $name: $text" unless $pid && $directory;
    my $deadline = time + 300;
    while (time < $deadline) {
        sleep 30;
        my $result = call_tool({pid => 0 + $pid});
        my $message = $result->{content}[0]{text};
        next if $message =~ /STATUS: RUNNING/;
        write_file("$out/$name.json", encode_json($result));
        my $expected = $failure ? 'FAILED' : 'COMPLETE';
        like($message, qr/STATUS: $expected\b/, "$name status");
        is(!!$result->{isError}, !!$failure, "$name MCP error flag");
        my ($exit) = $message =~ /Exit code: (\d+)/;
        ok(defined($exit) && (($exit != 0) == !!$failure), "$name exit code");
        die "Unexpected job result: $message" unless $message =~ /STATUS: $expected\b/;
        return ($message, "$root/" . basename($directory));
    }
    die "Timed out polling $name\n";
}

my $custom = "$relative/custom logs/failure.txt";
my ($message) = job('custom_log_failure', {
    sas_codes_or_file => 'proc print data=work.mcp_http_missing_table; run;',
    output_file => $custom,
}, 1);
ok(-f $custom, 'custom log path exists');
like($message, qr/=== SAS Log ===/, 'full SAS log returned');
like($message, qr/ERROR: File WORK\.MCP_HTTP_MISSING_TABLE\.DATA does not exist\./,
    'missing-table diagnostic preserved');

job('session_create', {persistent => JSON::PP::true, session_id => $session,
    sas_codes_or_file => 'data work.mcp_http_state; value=8675309; run; proc print; run;'});
my (undef, $directory) = job('session_reuse', {
    persistent => JSON::PP::true, session_id => $session,
    sas_codes_or_file => 'proc print data=work.mcp_http_state; run; '
        . 'proc datasets library=work nolist; delete mcp_http_state; quit;',
});
opendir my $dh, $directory or die $!;
my @html = map { "$directory/$_" } grep { /^sas_res_.*\.html$/ } readdir $dh;
closedir $dh;
ok(@html && read_file($html[0]) =~ /8675309/, 'WORK value persisted across MCP calls');

my @files = map { "$relative/mcp_$token$_" } ('_a.csv', '_with space.csv');
for my $i (0 .. $#files) { write_file($files[$i], "id,value\n1," . (10 + $i) . "\n") }
my @remote = map { '~/' . basename($_) } @files;
my @dest = map { "$relative/download_" . basename($_) } @files;
my $transfer_error;
eval {
    job('archive_roundtrip', {upload_file => \@files, download_file => \@remote,
        download_local_path => \@dest});
    for my $i (0 .. $#files) {
        is(read_file($dest[$i]), read_file($files[$i]), 'archive round trip preserves bytes');
    }
    1;
} or $transfer_error = $@;
job('cleanup_uploaded_fixtures', {delete_file => \@remote});
die $transfer_error if $transfer_error;
job('missing_download', {download_file => "~/mcp_missing_$token.csv",
    download_local_path => "$relative/missing.csv"}, 1);
diag("Live MCP artifacts: $out");
done_testing();
