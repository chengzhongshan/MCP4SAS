#!/usr/bin/env perl
use strict; use warnings;
use FindBin qw($Bin);
use Cwd qw(abs_path);
use File::Temp qw(tempdir);
use Test::More;
die "Use --live [--oneshot]\n" unless @ARGV && shift(@ARGV) eq '--live';
my $oneshot=@ARGV && $ARGV[0] eq '--oneshot';
my $root=abs_path("$Bin/.."); chdir $root or die $!;
my $out=tempdir('SAS_Output_remote_directory_cleanup_XXXXXX',DIR=>$root,CLEANUP=>0);
my $tag='MCP4SAS_directory_test_'.time.'_'.$$;
my $session='dir_cleanup_'.time.'_'.$$;
local $ENV{OPEN_RESULT}=0; local $ENV{SAS_ODA_AUTOLOAD_MACROS}=0;
sub save {open my $fh,'>',$_[0] or die $!; print {$fh} $_[1]; close $fh or die $!;}
sub read_text {open my $fh,'<',$_[0] or return ''; local $/; return <$fh>;}
sub cli {
 my ($label,@args)=@_;
 my $pid=fork(); die $! unless defined $pid;
 if (!$pid) {open STDOUT,'>',"$out/$label.cli.log" or die $!; open STDERR,'>&STDOUT' or die $!;
   exec $^X,"$root/run_sas_codes_or_files_in_ODA.pl",@args,
     ($oneshot ? ('--no-persistent') : ('--persistent','--session-id',$session)),
     '--run-timeout-seconds',180,'--output-prefix',"$out/$label"; die $!;}
 waitpid($pid,0); return $?>>8;
}
sub log_text {return read_text("$out/$_[0]/output.html.info.txt").read_text("$out/$_[0].cli.log");}
sub submit {
 my ($label,$code)=@_;
 save("$out/$label.sas","%let testroot=%sysfunc(pathname(HOME))/$tag;\n$code");
 return cli($label,'--file',"$out/$label.sas");
}
sub verify {
 my ($label,$condition)=@_;
 is(submit($label,"data _null_; if $condition then put 'DIRECTORY_VERIFY_OK'; else put 'ERROR: directory fixture verification failed'; run;"),0,$label);
 like(log_text($label),qr/^DIRECTORY_VERIFY_OK\s*$/m,"$label calculation verified");
}
my $setup=<<'SAS';
data _null_;
 length root child nested $4096;
 root=dcreate('__TAG__',pathname('HOME'));
 if missing(root) then do; put 'ERROR: Could not create owned test root'; stop; end;
 child=dcreate('junk_1',root); nested=dcreate('inner',child);
 child=dcreate('junk_2',root); child=dcreate('keep',root);
run;
filename a "&testroot/junk_1/inner/value.txt";
filename b "&testroot/junk_2/value.txt";
filename c "&testroot/keep/value.txt";
filename d "&testroot/junk_file.txt";
data _null_; file a; put 'nested'; file b; put 'second'; file c; put 'keep'; file d; put 'regular file'; run;
filename a clear; filename b clear; filename c clear; filename d clear;
SAS
$setup =~ s/__TAG__/$tag/g;
my $rc=submit('setup',$setup);
is($rc,0,'create only uniquely named test directories');
BAIL_OUT("ODA setup failed; inspect $out/setup.cli.log") if $rc;
my @cleanup=('--delete-dir',"~/$tag",'--delete-directory-rgx','^junk_');
is(cli('preview',@cleanup,'--delete-directory-dry-run'),0,'preview succeeds');
like(log_text('preview'),qr/MCP4SAS_DIRECTORY_SUMMARY: matched=2 deleted=0 dry_run=1/,'preview excludes matching regular file');
verify('preview_preserved',q{fileexist("&testroot/junk_1/inner/value.txt") and fileexist("&testroot/junk_2/value.txt") and fileexist("&testroot/keep/value.txt")});
is(submit('stage_setup',q{data _null_; length path $4096; path=dcreate('_DELETE_',"&testroot"); run; filename s "&testroot/_DELETE_/sentinel.txt"; data _null_; file s; put 'preserve'; run; filename s clear;}),0,'create owned staging collision');
isnt(cli('stage_refused',@cleanup),0,'existing _DELETE_ prevents deletion');
like(log_text('stage_refused'),qr/ERROR: Refusing recursive deletion.*_DELETE_ already exists/,'staging collision diagnosed');
verify('collision_preserved',q{fileexist("&testroot/_DELETE_/sentinel.txt") and fileexist("&testroot/junk_1/inner/value.txt") and not fileexist("&testroot/._mcp4sas_directory_cleanup_lock")});
is(submit('stage_remove',q{filename s "&testroot/_DELETE_/sentinel.txt"; filename t "&testroot/_DELETE_"; data _null_; rc=fdelete('s'); rc=fdelete('t'); run; filename s clear; filename t clear;}),0,'remove only owned staging fixture');
is(cli('apply',@cleanup),0,'delete matching nonempty directories using remote macro');
like(log_text('apply'),qr/MCP4SAS_DIRECTORY_SUMMARY: matched=2 deleted=2 dry_run=0/,'both directory removals verified');
verify('apply_preserved',q{not fileexist("&testroot/junk_1") and not fileexist("&testroot/junk_2") and not fileexist("&testroot/_DELETE_") and not fileexist("&testroot/._mcp4sas_directory_cleanup_lock") and fileexist("&testroot/junk_file.txt") and fileexist("&testroot/keep/value.txt")});
is(cli('no_matches',@cleanup),0,'no-match cleanup succeeds');
like(log_text('no_matches'),qr/MCP4SAS_DIRECTORY_SUMMARY: matched=0 deleted=0 dry_run=0/,'no-match result explicit');
is(submit('cleanup',q{filename k "&testroot/keep/value.txt"; filename f "&testroot/junk_file.txt"; filename d "&testroot/keep"; filename r "&testroot"; data _null_; rc=fdelete('k'); rc=fdelete('f'); rc=fdelete('d'); rc=fdelete('r'); if fileexist("&testroot") then put 'ERROR: owned test root remains'; run; filename k clear; filename f clear; filename d clear; filename r clear;}),0,'remove remaining owned fixtures and test root');
diag("Live artifacts: $out"); done_testing();
