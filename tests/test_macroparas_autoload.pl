#!/usr/bin/env perl
use strict; use warnings;
use FindBin qw($Bin);
use lib "$Bin/../MCPDeps";
use SAS_ODA_Runner;
use File::Temp qw(tempdir);
use File::Spec;
use Test::More;

my $directory=tempdir(CLEANUP=>1);
my $runner=bless {local_macro_dir=>$directory}, 'SAS_ODA_Runner';
for my $autoload (0,1) {
    local $ENV{SAS_ODA_AUTOLOAD_MACROS}=$autoload;
    my ($code,$logs)=$runner->_process_dependencies(q{%macroparas(macrorgx=GTEx);proc print;run;});
    like($code,qr/%macro macroparas\(/,"autoload=$autoload compiles portable fallback in caller's session");
    like($code,qr/options _last_=&output_macropara_dsd;/,'implicit PROC PRINT points at result table');
    unlike($code,qr/FileOrDirExist\.sas|stjude/i,'no legacy dependency or institutional share probe');
}
is_deeply([SAS_ODA_Runner::_expanded_targeted_remote_macro_names(['macroparas'])],['macroparas'],'no obsolete helper expansion');
{
    local $ENV{SAS_ODA_AUTOLOAD_MACROS}=0;
    no warnings 'redefine';
    local *SAS_ODA_Runner::upload=sub { return '/home/test/custom_utility.sas'; };
    my $file=File::Spec->catfile($directory,'custom_utility.sas');
    open my $fh,'>',$file or die $!;
    print {$fh} '%macro macroparas(macrorgx=); %put USER_VERSION; %mend;'; close $fh;
    my ($code)=$runner->_process_dependencies(qq{%include "$file"; %macroparas(macrorgx=GTEx);});
    unlike($code,qr/portable macroparas fallback/,'explicit include keeps user definition');
    ($code)=$runner->_process_dependencies(q{%macro macroparas(macrorgx=); %put USER_VERSION; %mend; %macroparas(macrorgx=GTEx);});
    unlike($code,qr/portable macroparas fallback/,'inline definition keeps user definition');
    my $local=File::Spec->catfile($directory,'macroparas.sas');
    rename $file,$local or die $!;
    ($code)=$runner->_process_dependencies(q{%macroparas(macrorgx=GTEx);});
    unlike($code,qr/portable macroparas fallback/,'explicit macro directory keeps user definition');
}
for my $entry (qw(run_sas_codes_or_files_in_ODA.pl run_sas_codes_or_script_in_ODA.pl)) {
    open my $fh,'<',"$Bin/../$entry" or die $!;
    my $source=do {local $/;<$fh>};close $fh;
    my ($function)=$source =~ /^(sub valid_sas_home_path \{.*?^\})/ms;
    no warnings 'redefine'; eval $function; die $@ if $@;
    ok(valid_sas_home_path('C:/Users/reader/SAS home'),"$entry accepts native Windows HOME");
    ok(valid_sas_home_path('C:\\Users\\reader\\SAS home'),'Windows backslashes accepted');
    ok(valid_sas_home_path('/home/reader'),'ODA HOME accepted');
    ok(!valid_sas_home_path('PYTHON ERROR: unavailable'),'failed lookup is not a HOME path');
    ok(!valid_sas_home_path('relative-path'),'relative path rejected');
}
done_testing;
