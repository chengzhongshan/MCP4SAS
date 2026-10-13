#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib $Bin;
use Test::More;
use SAS_ODA_Runner;

my $runner = bless {}, 'SAS_ODA_Runner';
my $uploads = 0;
{
    no warnings 'redefine';
    local *SAS_ODA_Runner::_find_local_macro_bootstrap_helper =
        sub { "$Bin/importallmacros_ue.sas" };
    local *SAS_ODA_Runner::upload = sub {
        $uploads++;
        return '/home/test/importallmacros_ue.sas';
    };
    local $ENV{SAS_ODA_REUSE_VERIFIED_MACRO_BOOTSTRAP_HELPER} = 1;
    like($runner->_ensure_remote_macro_bootstrap_helper(),
        qr/Reusing previously verified remote macro bootstrap helper/,
        'later locus reuses the verified bootstrap helper');
    is($uploads, 0, 'later locus opens no upload/check connection');

    $ENV{SAS_ODA_REUSE_VERIFIED_MACRO_BOOTSTRAP_HELPER} = 0;
    like($runner->_ensure_remote_macro_bootstrap_helper(),
        qr/Checked\/reused\/uploaded macro bootstrap helper/,
        'first locus still verifies the bootstrap helper');
    is($uploads, 1, 'first locus performs the bootstrap helper check');
}

done_testing();
