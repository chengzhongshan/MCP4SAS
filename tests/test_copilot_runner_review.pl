#!/usr/bin/env perl
use strict;use warnings;use FindBin qw($Bin);use Test::More;
use File::Temp qw(tempdir);use JSON::PP qw(decode_json);
my $directory=tempdir(CLEANUP=>1);
for my $entry(qw(run_sas_codes_or_files_in_ODA.pl run_sas_codes_or_script_in_ODA.pl)) {
    my $path="$Bin/../$entry";
    open my $fh,'<',$path or die $!;
    my $source=do{local $/;<$fh>};close $fh;
    my ($function)=$source=~/^(sub sas_log_contains_windows_network_path_failure \{.*?^\})/ms;
    die 'Network failure helper missing' unless $function;
    {no warnings 'redefine';eval $function;die $@ if $@;}
    my $error='ERROR: Windows error code: 67 in hx_disk_access';
    ok(sas_log_contains_windows_network_path_failure($error),"$entry detects runtime network failure");
    for my $text("12 $error","MPRINT(X): $error","NOTE: $error","=== SAS Log ===\nNOTE: done\n=== Output ===\n$error") {
        ok(!sas_log_contains_windows_network_path_failure($text),'source/output text cannot fabricate network failure');
    }
    my $log="$directory/network.log";
    open my $out,'>',$log or die $!;print {$out} "$error\n";close $out;
    open my $process,'-|',$^X,$path,'--classify-sas-log',$log or die $!;
    my $json=do{local $/;<$process>};close $process;
    is($?>>8,1,'saved network log returns nonzero');
    my $status=decode_json($json);
    is($status->{failure_class},'sas_windows_network_path_unavailable','saved-log classification matches submission');
    ok(!$status->{retryable},'network failure is not automatically replayed');
}
done_testing();
