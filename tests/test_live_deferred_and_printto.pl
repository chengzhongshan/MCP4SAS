#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);
use Cwd qw(abs_path);
use File::Temp qw(tempdir);
use Test::More;
die "Use --live\n" unless @ARGV==1 && $ARGV[0] eq '--live';
my $root=abs_path("$Bin/.."); chdir $root or die $!;
my $out=tempdir('SAS_Output_deferred_printto_XXXXXX',DIR=>$root,CLEANUP=>0);
sub read_text {open my $fh,'<',$_[0] or die $!; local $/; return <$fh>;}
sub cli {
    my ($label,$file)=@_;
    my $pid=fork(); die $! unless defined $pid;
    if (!$pid) {open STDOUT,'>',"$out/$label.runner.log" or die $!; open STDERR,'>&STDOUT' or die $!;
        exec $^X,"$root/run_sas_codes_or_files_in_ODA.pl",'--file',$file,'--output-prefix',"$out/$label",'--run-timeout-seconds',180; die $!;}
    waitpid($pid,0); return $?>>8;
}
local $ENV{SAS_ODA_AUTOLOAD_MACROS}=0; local $ENV{OPEN_RESULT}=0;
is(cli('success',"$root/examples/sas_library_deferred_quote_smoke.sas"),0,'deferred quote calculation succeeds through public CLI');
my $log=read_text("$out/success/output.html.info.txt");
like($log,qr/^LIBRARY_DEFERRED_QUOTE_OK\s*$/m,'computed marker retained');
unlike($log,qr/Injected targeted remote macro loader for: (?:deferred|immediate)_never_called/,'literal names do not cause uploads');
my @html=glob("$out/success/sas_res_*.html"); ok(@html && -s $html[0],'nonempty HTML retained');
open my $fh,'>',"$out/hidden.sas" or die $!;
print {$fh} "filename ownlog temp; proc printto log=ownlog new; run; data bad; set work.mcp_missing_$$; run; proc printto; run;\n"; close $fh;
ok(cli('hidden',"$out/hidden.sas")!=0,'redirected real SAS error returns nonzero exit');
$log=read_text("$out/hidden/output.html.info.txt");
like($log,qr/^ERROR: SAS submission ended with SYSCC=\d+/m,'condition code surfaces hidden error');
unlike($log,qr/^ERROR 180-322:/m,'status guard does not introduce syntax errors');
diag("Live artifacts: $out"); done_testing();
