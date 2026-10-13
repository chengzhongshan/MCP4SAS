#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib $Bin;
use SAS_ODA_Runner;
use Test::More;

for my $entry (qw(run_sas_codes_or_files_in_ODA.pl run_sas_codes_or_script_in_ODA.pl)) {
    open my $fh, '<', "$Bin/../$entry" or die $!;
    my $source = do { local $/; <$fh> };
    close $fh;
    for my $name (qw(sas_log_contains_fatal_error first_fatal_sas_log_line)) {
        my ($function) = $source =~ /^(sub $name \{.*?^\})/ms;
        die "Missing $name" unless $function;
        no warnings 'redefine';
        eval $function;
        die $@ if $@;
    }
    for my $line ('24  %put ERROR: not executed;',
        'MPRINT(TEST): message="ERROR: ordinary data";',
        'SYMBOLGEN: Macro variable TEXT resolves to ERROR: ordinary data',
        'NOTE: ERROR: is a literal label') {
        ok(!sas_log_contains_fatal_error($line), "$entry ignores source/trace text");
        is(first_fatal_sas_log_line($line), '', 'no false fatal summary');
    }
    for my $line ('ERROR: File WORK.MISSING.DATA does not exist.',
        'ERROR 180-322: Statement is not valid.',
        'WARNING: Apparent invocation of macro MISSING not resolved.') {
        ok(sas_log_contains_fatal_error($line), "$entry detects runtime failure");
        is(first_fatal_sas_log_line($line), $line, 'preserves the error detail');
    }
}
{
    local $ENV{SAS_ODA_AUTOLOAD_MACROS} = 0;
    no warnings 'redefine';
    local *SAS_ODA_Runner::_find_local_macro_file = sub { return };
    my $runner = bless {}, 'SAS_ODA_Runner';
    my ($code, $logs) = $runner->_process_dependencies(
        '%macro demo; %goto cleanup; %cleanup: %mend; %demo; %external_test;');
    unlike($code, qr{cleanup\.sas}, 'jump labels do not trigger remote loaders');
    like($code, qr{external_test\.sas}, 'real external macro still gets a loader');
}
done_testing();
