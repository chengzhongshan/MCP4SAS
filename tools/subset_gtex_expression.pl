#!/usr/bin/env perl
use strict; use warnings; use Getopt::Long qw(GetOptions);
use IO::Uncompress::Gunzip qw($GunzipError); use File::Basename qw(dirname); use File::Temp;
my ($input,$genes,$output);
GetOptions('input=s'=>\$input,'genes=s'=>\$genes,'output=s'=>\$output) or die 'Invalid options';
die "Usage: $0 --input MATRIX.tsv[.gz] --genes 'MAP3K19 R3HDM1' --output SUBSET.tsv\n" unless $input && $genes && $output;
die "Output already exists: $output\n" if -e $output;
my %wanted=map {uc($_)=>0} grep {length} split /[\s,]+/,$genes;
die "No gene symbols specified\n" unless keys %wanted;
my $in;
my $is_gzip=$input=~/\.gz$/i;
if ($is_gzip) {$in=IO::Uncompress::Gunzip->new($input,MultiStream=>1,Strict=>1) or die "Cannot open gzip: $GunzipError\n";}
else {open $in,'<:raw',$input or die "$input: $!\n";}
my $header=<$in>; die "Empty input matrix\n" unless defined $header;
my @columns=split /\t/,$header,-1; die "Matrix must be tab-delimited with sample columns\n" unless @columns>1;
my $tmp=File::Temp->new(TEMPLATE=>'.gtex-subset-XXXXXX',DIR=>dirname($output),UNLINK=>1);
binmode $tmp; print {$tmp} $header;
my ($read,$kept)=(0,0);
while (my $line=<$in>) {
    ++$read; my ($label)=split /\t/,$line,2;
    my $symbol=uc((split /\|/,$label)[-1]); next unless exists $wanted{$symbol};
    my @fields=split /\t/,$line,-1;
    die "Ragged selected matrix row $read for $symbol\n" unless @fields==@columns;
    print {$tmp} $line; ++$wanted{$symbol}; ++$kept;
}
die "Corrupt gzip matrix: ".$in->error."\n" if $is_gzip && $in->error;
close $in or die "Failed reading matrix: $!\n";
my @missing=sort grep {!$wanted{$_}} keys %wanted;
die "Missing requested genes: @missing\n" if @missing;
my $path=$tmp->filename; close $tmp or die "Cannot close subset: $!\n";
rename $path,$output or die "Cannot publish subset $output: $!\n";
print "Read $read matrix rows; retained $kept matching rows in $output. Input unchanged.\n";
