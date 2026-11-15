use strict;use warnings;use FindBin qw($Bin);use lib "$Bin/../MCPDeps";
use SAS_ODA_Runner;use Test::More;
{
 package HomeFake;our @ISA=('SAS_ODA_Runner');
 sub _call_persistent_session_server {return {status=>'ok',home=>'C:/actual/local/home'}}
}
local $ENV{SAS_ODA_REMOTE_HOME}='/home/oda.account';
my $runner=HomeFake->new(persistent=>1,session_id=>'offline-home-test');
for my $profile ('winlocal','linuxlocal','custom') {
 local $ENV{SASPY_CFGNAME}=$profile;
 is($runner->get_sas_home_path(),'C:/actual/local/home',"$profile bypasses ODA account shortcut");
}
local $ENV{SASPY_CFGNAME}='oda';
is($runner->get_sas_home_path(),'/home/oda.account','ODA shortcut retained for ODA target');
done_testing();
