#!/usr/bin/env perl
use strict; use warnings; use FindBin qw($Bin); use File::Temp qw(tempdir);
use IO::Compress::Gzip qw(gzip $GzipError); use Test::More;
my $dir=tempdir(CLEANUP=>1);
sub save {open my $f,'>:raw',$_[0] or die $!; print {$f} $_[1]; close $f;}
sub text {open my $f,'<:raw',$_[0] or die $!; local $/; return <$f>;}
sub run {
    my ($input,$output)=@_; my $pid=fork(); die $! unless defined $pid;
    if (!$pid) {open STDOUT,'>',"$dir/job.log" or die $!; open STDERR,'>&STDOUT' or die $!;
        exec $^X,"$Bin/../tools/subset_gtex_expression.pl",'--input',$input,'--output',$output,'--genes','MAP3K19 R3HDM1'; die $!;}
    waitpid($pid,0); return $?>>8;
}
my $source="gene\tS1\tS2\nENSG1|MAP3K19\t1\t2\nENSG2|OTHER\t3\t4\nR3HDM1\t5\t6\n";
my $expected="gene\tS1\tS2\nENSG1|MAP3K19\t1\t2\nR3HDM1\t5\t6\n";
save("$dir/input.tsv",$source);
is(run("$dir/input.tsv","$dir/plain.tsv"),0,'plain matrix is subset successfully');
is(text("$dir/plain.tsv"),$expected,'header and all requested expression values preserved');
is(text("$dir/input.tsv"),$source,'source unchanged');
gzip \$source=>"$dir/input.tsv.gz" or die $GzipError;
is(run("$dir/input.tsv.gz","$dir/gzip.tsv"),0,'gzip input is streamed');
is(text("$dir/gzip.tsv"),$expected,'gzip output matches plain output');
isnt(run("$dir/input.tsv","$dir/plain.tsv"),0,'existing output cannot be overwritten');
save("$dir/missing.tsv","gene\tS1\nMAP3K19\t1\n");
isnt(run("$dir/missing.tsv","$dir/missing-out.tsv"),0,'missing requested gene fails');
ok(!-e "$dir/missing-out.tsv",'incomplete subset is not published');
save("$dir/ragged.tsv","gene\tS1\tS2\nMAP3K19\t1\nR3HDM1\t2\t3\n");
isnt(run("$dir/ragged.tsv","$dir/ragged-out.tsv"),0,'ragged selected expression row fails');
ok(!-e "$dir/ragged-out.tsv",'ragged output is not published');
my $gzip=text("$dir/input.tsv.gz"); substr($gzip,-6)=''; save("$dir/truncated.tsv.gz",$gzip);
isnt(run("$dir/truncated.tsv.gz","$dir/truncated-out.tsv"),0,'truncated gzip fails rather than accepting a partial stream');
ok(!-e "$dir/truncated-out.tsv",'truncated subset is not published');
done_testing();
