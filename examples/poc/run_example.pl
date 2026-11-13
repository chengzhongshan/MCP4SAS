#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);
use Cwd qw(abs_path);
use File::Spec;
use File::Path qw(make_path);
use File::Basename qw(dirname);
use Getopt::Long qw(GetOptions);
use JSON::PP qw(decode_json encode_json);
use POSIX qw(strftime);

my ($id, $outdir, $session, $list, $dry, $help);
GetOptions('case=s'=>\$id, 'outdir=s'=>\$outdir, 'session-id=s'=>\$session,
    'list'=>\$list, 'dry-run'=>\$dry, 'help'=>\$help) or die "Use --help\n";
if ($help) {
    print "Usage: perl examples/poc/run_example.pl --case hello [--outdir DIR] [--session-id ID] [--dry-run]\n";
    print "Use --list for cases. Configure SASPy/ODA through MCP4SAS first. No AI agent is required.\n";
    exit;
}
sub read_text { open my $f,'<:raw',$_[0] or die "Cannot read $_[0]: $!\n"; return do {local $/; <$f>}; }
my $manifest=decode_json(read_text("$Bin/manifest.json"));
if ($list) { print "$_->{id}\t$_->{program}\n" for @{$manifest->{cases}}; exit; }
die "Supply --case; use --list\n" unless defined $id;
my ($case)=grep {$_->{id} eq $id} @{$manifest->{cases}};
die "Unknown case '$id'; use --list\n" unless $case;
my $root=abs_path("$Bin/../..");
my $runner=File::Spec->catfile($root,'run_sas_codes_or_files_in_ODA.pl');
die "MCP4SAS runner not found\n" unless -f $runner;
my $stamp=strftime('%Y%m%d_%H%M%S',localtime);
$session //= 'poc_showcase';
die "Use letters, numbers, underscores or hyphens in a session ID\n" unless $session =~ /^[A-Za-z0-9_-]+$/;
$outdir //= File::Spec->catdir($root,"SAS_Output_PoC_${id}_${stamp}_$$");
$outdir=File::Spec->rel2abs($outdir);
die "Output directory already exists; choose a new --outdir\n" if -e $outdir && !$dry;
my @common=($^X,$runner,'--persistent','--session-id',$session,
    '--run-timeout-seconds','600');
my @submit=(@common,'--file',File::Spec->catfile($Bin,$case->{program}),
    '--output-prefix',File::Spec->catdir($outdir,'submit'));
push @submit,('--upload-file',File::Spec->catfile($Bin,$_->{file})) for @{$case->{inputs}};
if ($dry) {
    print JSON::PP->new->canonical->pretty->encode({case=>$id,session_id=>$session,
        submit_argv=>\@submit,collect_files=>$case->{files},outdir=>$outdir,
        note=>'Plan only; no directory created, upload or SAS connection performed.'});
    exit;
}
make_path($outdir);
# The frozen programs contain their required macro definitions. Leave syntax
# and dependency checks at the user's configured settings; do not disable them.
local $ENV{SAS_ODA_AUTOLOAD_MACROS}=0;
local $ENV{PERLMCP_SASPY_LOAD_MACROS}=0;
local $ENV{OPEN_RESULT}=0;
sub run_checked {
    my @command=@_;
    system {$command[0]} @command;
    die "Runner failed (status=$?); inspect $outdir\n" if $? != 0;
}
run_checked(@submit);
my $log_path=File::Spec->catfile($outdir,'submit','output.html.info.txt');
my $log=read_text($log_path);
die "SAS log has ERROR lines; inspect $log_path\n" if $log =~ /^\s*ERROR(?:\s+\d+-\d+)?:/m;
die "Missing completion marker; inspect $log_path\n" unless $log =~ /^\Q$case->{completion_marker}\E\s*$/m;
my ($remote)=$log =~ /^POC_OUT=([^\r\n]+)\s*$/m;
die "No WORK output location in $log_path\n" unless defined($remote) && length($remote);
$remote =~ s/\s+\z//;
my $files=File::Spec->catdir($outdir,'files'); make_path($files);
my @collect=(@common,'--output-prefix',File::Spec->catdir($outdir,'collect'));
for my $file (@{$case->{files}}) {
    die "Invalid manifest output path\n" unless $file =~ m{^[A-Za-z0-9_.-]+(?:/[A-Za-z0-9_.-]+)*$} && $file !~ m{(?:^|/)\.\.?(?:/|$)};
    my $local=File::Spec->catfile($files,split m{/},$file);
    make_path(dirname($local));
    push @collect,('--download-file',"$remote/$file",'--download-local-path',$local);
}
run_checked(@collect);
run_checked($^X,"$Bin/validate_outputs.pl",'--case',$id,'--dir',$files);
my @warnings=$log =~ /^(WARNING:[^\r\n]*)/mg;
open my $report,'>',File::Spec->catfile($outdir,'run.json') or die $!;
print {$report} JSON::PP->new->canonical->pretty->encode({case=>$id,
    session_id=>$session,log=>$log_path,files=>$files,warnings=>\@warnings,
    scope=>'Saved-program execution and numerical checks; no AI authoring or token benchmark.'});
close $report;
print "Example $id collected and checked: $files\n";
print "SAS warnings retained: ",scalar(@warnings),". Read the complete log: $log_path\n";
print "WORK remains in persistent session $session until that session ends.\n";
