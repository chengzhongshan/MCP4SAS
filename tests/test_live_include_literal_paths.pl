#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);
use Cwd qw(abs_path);
use File::Temp qw(tempdir);
use File::Basename qw(basename);
use JSON::PP qw(decode_json);
use Test::More;
die "Use --live\n" unless @ARGV==1 && $ARGV[0] eq '--live';
my $root=abs_path("$Bin/.."); chdir $root or die $!;
my $out=tempdir('SAS_Output_include_paths_XXXXXX',DIR=>$root,CLEANUP=>0);
my $token=time.'_'.$$;
my $child="$out/include_${token}_author's file.sas";
my $program="$out/main.sas";
sub write_text {open my $fh,'>',$_[0] or die $!; print {$fh} $_[1]; close $fh;}
sub read_text {open my $fh,'<',$_[0] or die $!; local $/; return <$fh>;}
write_text($child,"data include_library; value=7; run;\n");
write_text($program,"%let masked=%nrstr(%include \"never_${token}.sas\";);\n%include \"$child\";\ndata _null_; set include_library; if value=7 then put 'INCLUDE_LIBRARY_PATH_OK'; else put 'ERROR: include path check failed'; run; proc print data=include_library; run;\n");
local $ENV{SAS_ODA_AUTOLOAD_MACROS}=0; local $ENV{OPEN_RESULT}=0;
sub cli {
    my ($log,@args)=@_;
    my $pid=fork(); die $! unless defined $pid;
    if (!$pid) {open STDOUT,'>',$log or die $!; open STDERR,'>&STDOUT' or die $!;
        exec $^X,"$root/run_sas_codes_or_files_in_ODA.pl",@args; die $!;}
    waitpid($pid,0); return $?>>8;
}
my $rc=cli("$out/runner.log",'--file',$program,'--output-prefix',"$out/result",'--run-timeout-seconds',180);
is($rc,0,'real include with apostrophe and space completes');
my $log=-f "$out/result/output.html.info.txt" ? read_text("$out/result/output.html.info.txt") : '';
like($log,qr/^INCLUDE_LIBRARY_PATH_OK\s*$/m,'included calculation completed');
unlike($log,qr/Target: .*never_\Q$token\E/,'NRSTR include is not preflighted as an active file');
my @html=glob("$out/result/sas_res_*.html");
ok(@html && -s $html[0],'HTML retained');
my $cleanup=cli("$out/cleanup.log",'--delete-file','~/'.basename($child),'--output-prefix',"$out/cleanup");
is($cleanup,0,'only the unique uploaded include fixture is removed');
diag("Live include artifacts: $out"); done_testing();
