#!/usr/bin/env perl
use strict; use warnings;
use FindBin qw($Bin);
use lib "$Bin/../MCPDeps";
use SAS_ODA_Directory_Cleanup;
use SAS_ODA_Runner;
use SAS_Source_Analysis;
use Test::More;
my $preview=SAS_ODA_Directory_Cleanup::build_code(parent=>'~/scratch',patterns=>['^tmp_','^old_'],dry_run=>1);
like($preview,qr/parent='~\/scratch'/,'parent kept as SAS literal');
like($preview,qr/prxmatch\(re\[0\+1\].* or prxmatch/s,'multiple patterns combined');
unlike($preview,qr/%Del_Dir_Recursive\(|%include/,'preview cannot load or invoke recursive macro');
like($preview,qr/child=dopen/,'only directories selected');
like($preview,qr/MCP4SAS_DIRECTORY_SUMMARY/,'preview has machine-readable summary');
{
 local $ENV{SAS_ODA_AUTOLOAD_MACROS}=0;
 my (undef,$log)=(bless {},'SAS_ODA_Runner')->_process_dependencies($preview);
 unlike($log,qr/Injected targeted remote macro loader/,'preview does not mistake builtin macro functions for remote dependencies');
}
my $apply=SAS_ODA_Directory_Cleanup::build_code(parent=>'~',patterns=>['^SAS_Output_']);
like($apply,qr{Macros/Del_Dir_Recursive\.sas},'remote macro path explicit');
like($apply,qr{%include "&_mcp_macro"},'remote macro explicitly included');
like($apply,qr/%Del_Dir_Recursive\(%superq\(_mcp_parent\),%superq\(_mcp_name\)\)/,'correct positional macro parameters');
like($apply,qr/fileexist\(trim\(path\)\).*fileexist\(trim\(staging\)\)/s,'both original and staging removal verified');
like($apply,qr/Refusing recursive deletion.*_DELETE_ already exists/,'existing staging directory protected');
like($apply,qr/Refusing protected or macro-unsafe/,'dangerous names rejected before deleting');
like($apply,qr/dcreate\('\._mcp4sas_directory_cleanup_lock'/,'operations on the same parent acquire a directory lock');
like($apply,qr/if deleted ne 0 then put 'ERROR:/,'lock removal failure is not hidden');
is_deeply(SAS_Source_Analysis::analyze_source($apply)->{findings},[],'generated apply program has balanced SAS quotes/comments');
is_deeply(SAS_Source_Analysis::analyze_source($preview)->{findings},[],'generated preview has balanced SAS quotes/comments');
{
 local $ENV{SAS_ODA_AUTOLOAD_MACROS}=0;
 my (undef,$dependency_log)=(bless {},'SAS_ODA_Runner')->_process_dependencies($apply);
 unlike($dependency_log,qr/(?:for: to\b|to[.]sas)/i,'macro loop %to keyword does not trigger a targeted macro lookup');
}
for my $bad ('/','~/../Macros','relative','~/bad&macro','~/bad;code') {
 eval {SAS_ODA_Directory_Cleanup::build_code(parent=>$bad,patterns=>['^tmp'])};
 ok($@,"unsafe parent rejected: $bad");
}
for my $bad ('','[',"tmp\n") {
 eval {SAS_ODA_Directory_Cleanup::build_code(patterns=>[$bad])};
 ok($@,'invalid regex rejected locally');
}
my $quoted=SAS_ODA_Directory_Cleanup::build_code(patterns=>[q{^a'b/c$}],dry_run=>1);
like($quoted,qr/a''b\\\/c/,'regex quotes and delimiter escaped without macro interpolation');
is_deeply(
 SAS_ODA_Directory_Cleanup::exact_name_patterns(['mgxviz_123','plot.v1']),
 ['^mgxviz_123$','^plot\\.v1$'],
 'matched directory basenames become exact escaped cleanup patterns',
);
my $named=SAS_ODA_Directory_Cleanup::build_code(parent=>'~',names=>['mgxviz_123','plot.v1']);
like($named,qr{prxparse\('/\(\?:\^mgxviz_123\$\)/'\)},'first exact directory name is anchored');
like($named,qr{prxparse\('/\(\?:\^plot\\\.v1\$\)/'\)},'regex metacharacters in exact directory names are escaped');
for my $bad_name ('../escape','Macros','_DELETE_','bad&macro') {
 eval {SAS_ODA_Directory_Cleanup::exact_name_patterns([$bad_name])};
 ok($@,"unsafe exact directory name rejected: $bad_name");
}
for my $autoload (0,1) {
 local $ENV{SAS_ODA_AUTOLOAD_MACROS}=$autoload;
 my $runner=bless {},'SAS_ODA_Runner';
 my ($code,$log)=$runner->_process_dependencies(q{%del_dir_recursive(/home/test,owned);});
 like($code,qr{wanted='Del_Dir_Recursive\.sas'},"canonical filename loaded with autoload=$autoload");
 like($log,qr/Injected targeted remote macro loader for: Del_Dir_Recursive/,"explicit remote loading with autoload=$autoload");
 unlike($log,qr/Uploaded overlay/,'remote macro not overwritten by a local copy');
}
open my $fh,'<',"$Bin/../server.pl" or die $!; my $server=do {local $/; <$fh>}; close $fh;
like($server,qr/delete_directory_rgx =>/,'MCP schema exposes directory regex');
like($server,qr/delete_directory_dry_run =>/,'MCP schema exposes preview');
like($server,qr/\('--delete-directory-rgx', \$_\)/,'MCP forwards every regex');
like($server,qr/delete_file_rgx.*?recursively deleting matching immediate-child directories/s,
    'MCP schema documents recursive directories for file regex deletion');
for my $entry (qw(run_sas_codes_or_files_in_ODA.pl run_sas_codes_or_script_in_ODA.pl)) {
 open my $cli,'<',"$Bin/../$entry" or die $!; my $text=do {local $/; <$cli>}; close $cli;
 like($text,qr/!\@delete_directory_rgxs && sas_submission_contains_include\(\$code\)/,"$entry keeps cleanup errors in the primary SAS log");
 like($text,qr/if \(\$entry =~ m\{\/\$\}\).*?\$selected_directories\{\$directory_name\}/s,
    "$entry separates matched directory entries from regular files");
 like($text,qr/SAS_ODA_Directory_Cleanup::build_code\(\s*parent => \$delete_dir,\s*names => \\\@directory_names/s,
    "$entry sends exact matched names to guarded recursive cleanup");
 like($text,qr/MCP4SAS_DIRECTORY_SUMMARY:.*matched=\$directory_count.*deleted=\$directory_count/s,
    "$entry requires a verified recursive deletion summary");
 like($text,qr/--delete-file-rgx <regex>\s+Delete matching remote files and recursively delete matching immediate-child directories/,
    "$entry help documents recursive directory deletion for --delete-file-rgx");
}
done_testing();
