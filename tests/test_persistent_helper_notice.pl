#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../MCPDeps";
use SAS_ODA_Runner;
use Test::More;

my $notice=SAS_ODA_Runner::_existing_helper_update_notice({status=>'ok'});
like($notice,qr/predates the current performance fixes/,'old helper is identified');
like($notice,qr/WORK sessions are being preserved/,'notice explains preservation of existing WORK');
like($notice,qr/unused port/,'notice explains how a fresh helper can be isolated');
is(SAS_ODA_Runner::_existing_helper_update_notice({runtime_revision=>'2026-11-22-efficient-submit'}),'','current helper needs no update notice');
is(SAS_ODA_Runner::_existing_helper_update_notice({runtime_revision=>'future-compatible-revision'}),'','later compatible helper does not trigger an older-revision warning');
like(SAS_ODA_Runner::_session_server_source(),qr/runtime_revision.*2026-11-22-efficient-submit/,'generated helper advertises its implementation revision');
done_testing();
