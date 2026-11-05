#!/usr/bin/env perl
use strict; use warnings; use FindBin qw($Bin); use lib "$Bin/../MCPDeps";
use Cwd qw(abs_path); use File::Temp qw(tempdir); use JSON::PP qw(decode_json); use SAS_Evaluation_Log; use Test::More;
plan skip_all=>'Use --live for bounded synthetic SAS ODA tests' unless grep {$_ eq '--live'} @ARGV;
my $root=abs_path("$Bin/.."); chdir $root or die $!;
sub text {open my $f,'<:raw',$_[0] or die $!; local $/; return <$f>;}
sub save {open my $f,'>:raw',$_[0] or die $!; print {$f} $_[1]; close $f;}
my $out=tempdir('SAS_Output_gtex_cache_XXXXXX',DIR=>$root,CLEANUP=>0);
my $macro=text("$root/examples/sas_macros/Boxplots4GenesInGTExV8_Cached.sas");
local $ENV{OPEN_RESULT}=0; local $ENV{SAS_ODA_AUTOLOAD_MACROS}=0;
my $data=q{data work.probe_cache; length rownames $16 cluster $8 sex $1;
do gene=1 to 3; if gene=1 then rownames='MAP3K19'; else if gene=2 then rownames='R3HDM1'; else rownames='OTHER';
do tissue=1 to 2; cluster=cats('t',tissue); do j=1 to 2; sex='F'; exp=j; output; sex='M'; exp=j+1; output; end; end; end; run;};
my @cases=(
 ['cached',"$data\n%Boxplots4GenesInGTExV8_Cached(Lib4PreviousDsd=work,PreviousDsd=probe_cache,dsdout=probe_out);\n".
 q{proc sql noprint; select count(*) into :outn from probe_out; select count(*) into :inn from probe_cache; quit;
 %if &outn=16 and &inn=24 %then %do; %put GTEX_PASS=cached; %end; %else %do; %put ERROR: Cache or subset counts invalid; %end;},undef],
 ['missing',q{%Boxplots4GenesInGTExV8_Cached(Lib4PreviousDsd=work,PreviousDsd=probe_absent,dsdout=probe_out);},'GTEX_CACHE_ONLY: Prepared long dataset.*does not exist'],
 ['rebuild',q{%Boxplots4GenesInGTExV8_Cached(UseGeneratedDsd=0);},'GTEX_CACHE_ONLY: Set UseGeneratedDsd=1'],
);
for my $case (@cases) {
    my ($id,$code,$diagnostic)=@$case; my $prefix="$out/$id"; save("$prefix.sas","$macro\n$code\n");
    my $pid=fork(); die $! unless defined $pid;
    if (!$pid) {open STDOUT,'>',"$prefix.cli.log" or die $!; open STDERR,'>&STDOUT' or die $!;
        exec $^X,"$root/run_sas_codes_or_files_in_ODA.pl",'--file',"$prefix.sas",'--output-prefix',$prefix,'--run-timeout-seconds',120; die $!;}
    waitpid($pid,0); my $rc=$?>>8;
    my $status=decode_json(text("$prefix/output.run.status.json"));
    my $evaluation=SAS_Evaluation_Log::evaluate(report=>text("$prefix/output.html.info.txt"),marker=>'GTEX_PASS',expected=>[$id],exit_code=>$rc,
        expected_failure=>defined($diagnostic)?1:0,diagnostic=>$diagnostic,status=>$status,require_status=>1);
    ok($evaluation->{passes}{$id},"$id: expected runtime result, exit and complete terminal status");
    if (!$evaluation->{passes}{$id}) {diag(join "\n",@{$evaluation->{errors}}); diag($status->{message}//'');}
}
diag("GTEx synthetic cache artifacts: $out"); done_testing();
