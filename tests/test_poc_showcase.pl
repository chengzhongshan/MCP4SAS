#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use FindBin qw($Bin);
use Cwd qw(abs_path);
use File::Spec;
use File::Temp qw(tempdir);
use Digest::SHA qw(sha256_hex);
use JSON::PP qw(decode_json);
use IPC::Open3;
use Symbol qw(gensym);

my $root=abs_path("$Bin/..");
my $example="$root/examples/poc";
sub bytes { open my $f,'<:raw',$_[0] or die "$!: $_[0]"; local $/; return <$f>; }
sub command {
    my @argv=@_;
    my $err=gensym;
    my $pid=open3(undef,my $out,$err,@argv);
    my $stdout=do {local $/; <$out>}//'';
    my $stderr=do {local $/; <$err>}//'';
    waitpid($pid,0);
    return ($? >> 8,$stdout,$stderr);
}
my $manifest=decode_json(bytes("$example/manifest.json"));
is(scalar(@{$manifest->{cases}}),6,'beginner example and five scientific cases');
my %seen;
for my $case (@{$manifest->{cases}}) {
    ok(!$seen{$case->{id}}++,'unique case '.$case->{id});
    is(sha256_hex(bytes("$example/$case->{program}")),$case->{sha256},"$case->{id} frozen program hash");
    like(bytes("$example/$case->{program}"),qr/\Q$case->{completion_marker}\E/,"$case->{id} completion marker in source");
    for my $input (@{$case->{inputs}}) {
        is(sha256_hex(bytes("$example/$input->{file}")),$input->{sha256},"$case->{id} input hash");
    }
    for my $file (@{$case->{files}}) {
        ok($file =~ m{^[A-Za-z0-9_.-]+(?:/[A-Za-z0-9_.-]+)*$} && $file !~ m{(?:^|/)\.\.?(?:/|$)},"safe output $file");
        ok(defined($case->{expected_csv_rows}{$file}),"expected row count $file") if $file=~/\.csv$/;
    }
}
is_deeply([sort keys %seen],[sort qw(hello clustergram gene_gtf oncoprint forest multi_gwas_gtf)],'documented case IDs');
is(scalar(@{$manifest->{source_documents}}),2,'two Word originals');
for my $doc (@{$manifest->{source_documents}}) {
    is(sha256_hex(bytes("$root/docs/poc/$doc->{file}")),$doc->{sha256},'unchanged author document '.$doc->{file});
}
my @png=glob("$root/docs/poc/figures/*.png");
is(scalar(@png),6,'six original embedded figures');
for my $png (@png) { is(substr(bytes($png),0,8),"\x89PNG\r\n\x1a\n",'PNG signature '.$png); }
for my $path (glob("$root/docs/poc/*.md"),glob("$example/*.md")) {
    my $text=bytes($path);
    my @fences=$text=~/^```/mg;
    is(@fences%2,0,"balanced code fences $path");
    my (undef,$parent)=File::Spec->splitpath($path);
    for my $target ($text=~/\]\(([^)]+)\)/g) {
        next if $target=~/^(?:https?:|mailto:|#)/;
        $target=~s/[?#].*//;
        ok(-f File::Spec->catfile($parent,$target),"local link $target");
    }
}
like(bytes("$root/docs/poc/README.md"),qr/\*\*Synthetic\*\*/,'synthetic oncoprint identified');
like(bytes("$root/docs/poc/README.md"),qr/not completed trials/,'agent benchmark not implied');
like(bytes("$root/README.md"),qr{docs/poc/README\.md},'homepage links showcase');
my $temp=tempdir(CLEANUP=>1);
my ($status,$stdout,$stderr)=command($^X,"$example/run_example.pl",'--list');
is($status,0,'list works without SAS');
for my $case (@{$manifest->{cases}}) {
    like($stdout,qr/^\Q$case->{id}\E\t/m,'listed '.$case->{id});
    my $outdir="$temp/not-created-$case->{id}";
    my ($exit,$output,$errors)=command($^X,"$example/run_example.pl",'--case',$case->{id},'--outdir',$outdir,'--dry-run');
    is($exit,0,"$case->{id} dry-run succeeds") or diag($errors);
    my $plan=eval {decode_json($output)};
    ok($plan,"$case->{id} dry-run JSON");
    is($plan->{session_id},'poc_showcase','consistent default session');
    is(scalar(grep {$_ eq '--upload-file'} @{$plan->{submit_argv}}),scalar(@{$case->{inputs}}),'all explicit inputs staged');
    ok(!-e $outdir,'dry-run creates no output directory');
}
($status,$stdout,$stderr)=command($^X,"$example/run_example.pl",'--case','unknown');
ok($status!=0 && $stderr=~/Unknown case/,'unknown case fails clearly');
($status,$stdout,$stderr)=command($^X,"$example/run_example.pl",'--case','hello','--session-id','bad/session','--dry-run');
ok($status!=0 && $stderr=~/session ID/,'unsafe session ID rejected');
my $bad="$temp/bad";mkdir $bad or die $!;
open my $csv,'>',"$bad/hello.csv" or die $!;
print {$csv} "Name,Age\nOnlyOne,12\n";close $csv;
($status,$stdout,$stderr)=command($^X,"$example/validate_outputs.pl",'--case','hello','--dir',$bad);
ok($status!=0 && $stderr=~/expected row count/,'checker rejects an incomplete returned table');
done_testing;
