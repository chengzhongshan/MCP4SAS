#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../MCPDeps";
use SAS_ODA_Runner;
use Test::More;
for my $persistent (0,1) {
    my ($action,$payload);
    no warnings 'redefine';
    local *SAS_ODA_Runner::_run_nonpersistent_python_action=sub {
        ($action,$payload)=@_;
        return {status=>'ok',value=>{uploads=>[{remote_path=>q{/home/user/author's file.sas}}]}};
    };
    my $runner=bless {persistent=>$persistent,session_id=>'test'},'SAS_ODA_Runner';
    is($runner->upload(q{/tmp/author's file.sas},{skip_if_same=>0}),q{/home/user/author's file.sas},'quoted destination preserved');
    is($action,'bulk_transfer','both session modes use archive transfer');
    is($payload->{uploads}[0]{local_path},q{/tmp/author's file.sas},'original local path preserved');
    is($payload->{uploads}[0]{skip_if_same},0,'explicit refresh retained');
}
done_testing();
