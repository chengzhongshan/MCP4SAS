#!/usr/bin/env perl
use strict;use warnings;use FindBin qw($Bin);use lib "$Bin/../MCPDeps";
use SAS_ODA_Runner;use Test::More;use File::Temp qw(tempdir);use File::Path qw(make_path);use File::Basename qw(basename);use Cwd qw(getcwd);
{
 package GraphRunner;our @ISA=('SAS_ODA_Runner');
 sub get_sas_home_path {$_[0]{home_calls}++;return '/sas-home';}
 sub upload {die 'Individual upload must not run for a batched graph';}
 sub transfer_many {
  my($self,$payload)=@_;push @{$self->{batches}},$payload;
  my @entries;
  for my $item(@{$payload->{uploads}}){
   open my $f,'<:raw',$item->{local_path} or die$!;local$/;
   $self->{contents}{File::Basename::basename($item->{local_path})}=<$f>;close$f;
   push @{$self->{staged}},$item->{local_path};
   push @entries,{%$item,remote_path=>'/sas-home/'.File::Basename::basename($item->{local_path})};
  }
  return {uploads=>\@entries};
 }
}
sub save{open my$f,'>:raw',$_[0] or die$!;print{$f}$_[1];close$f;}
my $temp=tempdir('include-graph-XXXX',TMPDIR=>1,CLEANUP=>1);
my $old=getcwd();chdir$temp or die$!;
local$ENV{SAS_ODA_AUTOLOAD_MACROS}=0;
make_path('with spaces','other');
save('with spaces/parent.sas',q{%include 'child.sas'; %put PARENT_FINISHED;});
save('with spaces/child.sas',q{%let fixture=42;});
my $original=do{open my$f,'<','with spaces/parent.sas' or die$!;local$/;<$f>};
my $runner=GraphRunner->new(batch_dependencies=>1,local_macro_dir=>$temp);
my($code,$log)=$runner->_process_dependencies(q{%include 'with spaces/parent.sas'; %include 'with spaces/parent.sas';});
is(scalar@{$runner->{batches}},1,'one bulk transfer for the whole recursive include graph');
is(scalar@{$runner->{batches}[0]{uploads}},2,'parent and child each uploaded once');
like($runner->{contents}{'parent.sas'},qr{%include '/sas-home/child\.sas'},'uploaded parent points at the uploaded child');
is($runner->{contents}{'child.sas'},q{%let fixture=42;},'leaf contents unchanged');
is(scalar(()=$code=~m{/sas-home/parent\.sas}g),2,'repeated root includes keep their source order and multiplicity');
is(do{open my$f,'<','with spaces/parent.sas' or die$!;local$/;<$f>},$original,'original local parent source is unchanged');
ok(!grep({-e$_}@{$runner->{staged}}),'owned temporary copies removed after transfer');
like($log,qr/recursive local include graph/,'recursive preparation recorded in dependency log');
save('with spaces/child.sas',q{%macro child_func; %put CHILD_BODY; %mend;});
my $with_macro=GraphRunner->new(batch_dependencies=>1,local_macro_dir=>$temp);
my($macro_code)=$with_macro->_process_dependencies(q{%include 'with spaces/parent.sas'; %child_func;});
unlike($macro_code,qr/wanted='child_func\.sas'/,'a definition supplied by explicit includes is not loaded again before its source statement');
like($macro_code,qr{%include '/sas-home/parent\.sas'; %child_func;},'macro call remains after the explicit parent include');
my $sibling=GraphRunner->new(batch_dependencies=>1,local_macro_dir=>$temp);
$sibling->{_dependency_source_dir}="$temp/with spaces";
my($sibling_code)=$sibling->_process_dependencies(q{%include 'child.sas';});
like($sibling_code,qr{%include '/sas-home/child\.sas'},'a file-relative include is rebased even when it has no children');
is(scalar@{$sibling->{batches}[0]{uploads}},1,'single file-relative include transfers only its source');
save('other/child.sas',q{%let other=7;});
save('duplicate.sas',q{%include 'with spaces/child.sas' 'other/child.sas';});
my $duplicates=GraphRunner->new(batch_dependencies=>1,local_macro_dir=>$temp);
eval{$duplicates->_process_dependencies(q{%include 'duplicate.sas';});};
like($@,qr/same remote basename/,'ambiguous child basenames fail before transfer');
is($duplicates->{home_calls}//0,0,'duplicate plan does not even request a SAS connection');
save('cycle_a.sas',q{%include 'cycle_b.sas';});save('cycle_b.sas',q{%include 'cycle_a.sas';});
eval{$runner->_local_include_graph(q{%include 'cycle_a.sas';});};
like($@,qr/Cyclic local SAS include dependency/,'cycles rejected before uploading source');
my $deferred=$runner->_local_include_graph(q{%include "&runtime_path/source.sas" '~/remote_only.sas';});
is(scalar@{$deferred->{order}},0,'runtime and server-only include paths remain deferred');
chdir$old or die$!;done_testing;
