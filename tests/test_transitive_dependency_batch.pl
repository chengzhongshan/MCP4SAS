use strict;use warnings;use FindBin qw($Bin);use lib "$Bin/../MCPDeps";
use SAS_ODA_Runner;use Test::More;use File::Temp qw(tempdir);use File::Spec;
{
 package BatchFake;our @ISA=('SAS_ODA_Runner');
 sub get_sas_home_path {die 'Dependency destinations must come from actual transfer results, not an ODA HOME guess'}
 sub upload {die 'Individual upload must not run in the batched plan'}
 sub transfer_many {
  my ($self,$payload)=@_;push @{$self->{calls}},$payload;
  return 'PYTHON ERROR: test transfer failed' if $self->{fail_transfer};
  return {uploads=>[map {{remote_path=>'/home/test/'.File::Basename::basename($_->{local_path})}} @{$payload->{uploads}}]};
 }
}
sub save {open my $f,'>',$_[0] or die $!;print {$f} $_[1];close $f;}
my $dir=tempdir('dependency-batch-XXXX',TMPDIR=>1,CLEANUP=>1);
save("$dir/parent.sas",'%macro parent; %child; %mend;');
save("$dir/child.sas",'%macro child; %if 0 %then %sysexec echo test; %mend;');
save("$dir/data.tsv","x\n1\n");
local $ENV{SAS_ODA_AUTOLOAD_MACROS}=0;
my $runner=BatchFake->new(local_macro_dir=>$dir,batch_dependencies=>1);
my ($code,$log)=$runner->_process_dependencies(qq{%parent; %parent; %read(zip=$dir/data.tsv,obs=2);});
is(scalar @{$runner->{calls}},1,'all local dependencies use one transfer request');
is_deeply([sort map {File::Basename::basename($_->{local_path})} @{$runner->{calls}[0]{uploads}}],
 [qw(child.sas data.tsv parent.sas)],'nested helper discovered once, reserved SYSEXEC excluded');
like($code,qr{zip=/home/test/data.tsv,},'unquoted input alias rewritten');
like($code,qr{%include "/home/test/child.sas"},'helper definition included before main program');
unlike($code,qr{MACRO_NAME=sysexec|checking.*sysexec},'reserved statement has no remote macro lookup');
ok($runner->{calls}[0]{archive_transfers},'archive batching enabled');
$runner->{fail_transfer}=1;
eval {$runner->_process_dependencies('%parent;')};like($@,qr/Dependency bulk upload failed/,'transfer failure stops submission');
mkdir "$dir/a";mkdir "$dir/b";save("$dir/a/same.tsv",'a');save("$dir/b/same.tsv",'b');
$runner->{calls}=[];$runner->{fail_transfer}=0;
eval {$runner->_process_dependencies(qq{infile "$dir/a/same.tsv"; infile "$dir/b/same.tsv";})};
like($@,qr/same remote basename/,'colliding basenames fail before transfers');
is(scalar @{$runner->{calls}},0,'collision does not upload either file');
done_testing();
