use strict;use warnings;use FindBin;use lib "$FindBin::Bin/../MCPDeps";use Test::More;use SAS_Source_Analysis;
ok(SAS_Source_Analysis::is_builtin_macro_name($_),"SAS supplied $_ needs no remote loader")for qw(left LEFT trim TRIM);
ok(!SAS_Source_Analysis::is_builtin_macro_name('my_left'),'custom macro remains dependency');
ok(!SAS_Source_Analysis::is_builtin_macro_name('clustergram4sas'),'plot macro remains dependency');done_testing;
