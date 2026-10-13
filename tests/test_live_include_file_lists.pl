#!/usr/bin/env perl
use strict; use warnings;
use FindBin qw($Bin);
use Cwd qw(abs_path);
use File::Temp qw(tempdir);
use File::Basename qw(basename);
use Test::More;
die "Use --live\n" unless @ARGV==1 && $ARGV[0] eq '--live';
my $root=abs_path("$Bin/.."); chdir $root or die $!;
my $entry=-f "$root/run_sas_codes_or_files_in_ODA.pl"
    ? "$root/run_sas_codes_or_files_in_ODA.pl" : "$root/run_sas_codes_or_files_in_SAS_ODA.pl";
die "Public runner missing: $entry\n" unless -f $entry;
my $out=tempdir('SAS_Output_include_lists_XXXXXX',DIR=>$root,CLEANUP=>0);
sub save {open my $fh,'>',$_[0] or die $!; print {$fh} $_[1]; close $fh or die $!;}
sub read_text {open my $fh,'<',$_[0] or die $!; local $/; return <$fh>;}
my @fixtures=map {"$out/list_".time.'_'.$$."_$_ file.sas"} (1,2);
save($fixtures[0],"data list_a; value_a=14; run;\n");
save($fixtures[1],"data list_b; value_b=19; run;\n");
local $ENV{SAS_ODA_AUTOLOAD_MACROS}=0; local $ENV{OPEN_RESULT}=0;
sub cli {
    my ($label,@args)=@_;
    my $pid=fork(); die $! unless defined $pid;
    if (!$pid) {open STDOUT,'>',"$out/$label.runner.log" or die $!; open STDERR,'>&STDOUT' or die $!;
        exec $^X,$entry,@args,'--output-prefix',"$out/$label"; die $!;}
    waitpid($pid,0); return $?>>8;
}
my $command='%include '.join(' ',map {my $p=$_; $p=~s/'/''/g; "'$p'"} @fixtures).';';
for my $api ('direct','dosubl','execute') {
    my $statement=$command;
    if ($api ne 'direct') {my $escaped=$command; $escaped=~s/'/''/g;
        $statement='data _null_; '.($api eq 'dosubl' ? "rc=dosubl('$escaped');" : "call execute('$escaped');").' run;';}
    my $program="$out/$api.sas";
    save($program,"$statement\ndata result; set list_a; set list_b; total=value_a+value_b; run;\ndata _null_; set result; if total=33 then put 'INCLUDE_LIST_OK'; else put 'ERROR: include list assertion'; run; proc print data=result; run;\n");
    is(cli($api,'--file',$program,'--run-timeout-seconds',180),0,"$api runs both files in include list");
    like(read_text("$out/$api/output.html.info.txt"),qr/^INCLUDE_LIST_OK\s*$/m,"$api computed sum verified");
    my @html=glob("$out/$api/sas_res_*.html"); ok(@html && -s $html[0],"$api HTML retained");
}
is(cli('cleanup',map {('--delete-file','~/'.basename($_))} @fixtures),0,'only the two uniquely named remote fixtures are deleted');
diag("Live artifacts: $out"); done_testing();
