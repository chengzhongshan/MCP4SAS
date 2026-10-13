#!/usr/bin/env perl
use strict; use warnings;
use FindBin qw($Bin);
use Cwd qw(abs_path);
use File::Temp qw(tempdir);
use File::Basename qw(basename);
use Test::More;
die "Use --live\n" unless @ARGV==1 && $ARGV[0] eq '--live';
my $root=abs_path("$Bin/.."); chdir $root or die $!;
my $out=tempdir('SAS_Output_deferred_includes_XXXXXX',DIR=>$root,CLEANUP=>0);
my $child="$out/include_".time.'_'.$$."_author's file.sas";
sub write_text {open my $fh,'>',$_[0] or die $!; print {$fh} $_[1]; close $fh;}
sub read_text {open my $fh,'<',$_[0] or die $!; local $/; return <$fh>;}
write_text($child,"data deferred_child; value=27; run;\n");
local $ENV{SAS_ODA_AUTOLOAD_MACROS}=0; local $ENV{OPEN_RESULT}=0;
sub cli {
    my ($label,@args)=@_;
    my $pid=fork(); die $! unless defined $pid;
    if (!$pid) {open STDOUT,'>',"$out/$label.runner.log" or die $!; open STDERR,'>&STDOUT' or die $!;
        exec $^X,"$root/run_sas_codes_or_files_in_ODA.pl",@args,'--output-prefix',"$out/$label"; die $!;}
    waitpid($pid,0); return $?>>8;
}
my $path=$child; $path =~ s/'/''/g;
my $command="%include '$path';"; $command =~ s/'/''/g;
for my $api ('dosubl','execute') {
    my $statement=$api eq 'dosubl' ? "rc=dosubl('$command');" : "call execute('$command');";
    my $program="$out/$api.sas";
    write_text($program,"data _null_; $statement run;\ndata _null_; set deferred_child; if value=27 then put 'DEFERRED_INCLUDE_OK'; else put 'ERROR: deferred include assertion'; run; proc print data=deferred_child; run;\n");
    is(cli($api,'--file',$program,'--run-timeout-seconds',180),0,"$api executes single-quoted apostrophe filename");
    my $log=read_text("$out/$api/output.html.info.txt");
    like($log,qr/^DEFERRED_INCLUDE_OK\s*$/m,"$api included calculation verified");
    my @html=glob("$out/$api/sas_res_*.html"); ok(@html && -s $html[0],"$api HTML retained");
}
is(cli('cleanup','--delete-file','~/'.basename($child)),0,'only the uniquely named remote fixture is deleted');
diag("Live artifacts: $out"); done_testing();
