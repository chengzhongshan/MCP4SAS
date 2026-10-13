#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);
use Cwd qw(abs_path);
use File::Temp qw(tempdir);
use Getopt::Long qw(GetOptions);
use Mojo::UserAgent;
use JSON::PP qw(encode_json);
use Test::More;
my ($live,$url)=(0,'http://127.0.0.1:18135/mcp');
GetOptions('live'=>\$live,'url=s'=>\$url) or die "Invalid options\n";
die "Use --live [--url URL]\n" unless $live;
my $root=abs_path("$Bin/.."); chdir $root or die $!;
my $out=tempdir('SAS_Output_library_probe_XXXXXX',DIR=>$root,CLEANUP=>0);
my $ua=Mojo::UserAgent->new; $ua->request_timeout(240); $ua->inactivity_timeout(240);
sub tool {
    my ($args)=@_;
    my $res=$ua->post($url=>{Connection=>'close'}=>json=>{jsonrpc=>'2.0',id=>1,method=>'tools/call',params=>{name=>'run_sas_codes_or_files_in_ODA',arguments=>$args}})->result;
    die 'HTTP failure' unless $res->is_success;
    my $body=$res->json; die encode_json($body) if $body->{error}; return $body->{result};
}
my @probes=(
    {name=>'flowover',sas=>"options notes;\nfilename pfile temp;\ndata _null_; file pfile; put 'ab'; run;\ndata probe; infile pfile; input value \$20.; run;\nproc print data=probe; run; filename pfile clear;",status=>'COMPLETE'},
    {name=>'format_name',sas=>"options notes;\nproc format; value bad1 1='one'; run;",status=>'FAILED'},
);
for my $probe (@probes) {
    my $start=tool({sas_codes_or_file=>$probe->{sas},persistent=>JSON::PP::false,run_timeout_seconds=>180});
    my ($pid)=$start->{content}[0]{text}=~/PID: (\d+)/;
    die 'No PID' unless $pid;
    my $deadline=time+300;
    my ($result,$text);
    while(time<$deadline) {
        sleep 5; $result=tool({pid=>0+$pid}); $text=$result->{content}[0]{text};
        last unless $text=~/STATUS: RUNNING/;
    }
    open my $fh,'>',"$out/$probe->{name}.json" or die $!;
    print {$fh} JSON::PP->new->canonical->pretty->encode($result); close $fh;
    is($result->{structuredContent}{status},$probe->{status},"$probe->{name} status");
    is(0+!!$result->{isError},$probe->{status} eq 'FAILED'?1:0,"$probe->{name} error flag");
    if($probe->{name} eq 'flowover') {
        cmp_ok($result->{structuredContent}{diagnostics}{data_quality_count},'>=',2,'input flowover and empty input surfaced through actual HTTP poll');
        like($text,qr/SAS went to a new line when INPUT statement reached past/, 'flowover detail retained');
    } else {
        like($text,qr/Use a letter suffix/, 'format advisory shown before remote submit');
        like($text,qr/ERROR: The format name BAD1 ends in a number/, 'SAS runtime failure retained; advisory did not replace remote execution');
    }
}
diag("Live diagnostic artifacts: $out"); done_testing();
