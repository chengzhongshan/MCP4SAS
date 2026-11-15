use strict;use warnings;
use FindBin qw($Bin);use lib "$Bin/../MCPDeps";
use Test::More;
use SAS_Source_Analysis;
ok(SAS_Source_Analysis::is_builtin_macro_name('sysexec'),'SYSEXEC is a SAS macro statement, not a custom source dependency');
ok(SAS_Source_Analysis::is_builtin_macro_name('SySeXeC'),'classification is case insensitive');
ok(!SAS_Source_Analysis::is_builtin_macro_name('my_sysexec'),'custom names are preserved');
done_testing();
