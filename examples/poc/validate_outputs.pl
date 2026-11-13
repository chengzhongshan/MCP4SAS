#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);
use Getopt::Long qw(GetOptions);
use JSON::PP qw(decode_json);
use List::Util qw(sum max);
my ($id,$dir);
GetOptions('case=s'=>\$id,'dir=s'=>\$dir) or die "Use --case ID --dir FILES_DIRECTORY\n";
die "Use --case ID --dir FILES_DIRECTORY\n" unless defined($id) && defined($dir);
sub bytes {open my $f,'<:raw',$_[0] or die "Cannot read $_[0]: $!\n"; return do {local $/; <$f>};}
my $manifest=decode_json(bytes("$Bin/manifest.json"));
my ($case)=grep {$_->{id} eq $id} @{$manifest->{cases}};
die "Unknown case $id\n" unless $case;
my $checks=0;
sub check {die "FAIL: $_[1]\n" unless $_[0];++$checks;}
sub csv {
    my ($text,$sep)=@_;$sep //= ',';
    my (@rows,@row,$value);$value='';my $quoted=0;
    for(my $i=0;$i<length($text);++$i){my $ch=substr($text,$i,1);
        if($ch eq '"'){
            if($quoted && substr($text,$i+1,1) eq '"'){$value.='"';++$i;}
            else{$quoted=!$quoted;}
        }elsif(!$quoted && $ch eq $sep){push @row,$value;$value='';}
        elsif(!$quoted && $ch eq "\n"){$value=~s/\r\z//;push @row,$value;push @rows,[@row];@row=();$value='';}
        else{$value.=$ch;}
    }
    die "Unclosed CSV quote\n" if $quoted;
    if(length($value)||@row){$value=~s/\r\z//;push @row,$value;push @rows,\@row;}
    my $header=shift @rows or die "Empty CSV\n";
    $header->[0]=~s/^\xEF\xBB\xBF//;
    my @objects;
    for my $row (@rows){die "CSV column mismatch\n" unless @$row==@$header;my %o;@o{map {lc} @$header}=@$row;push @objects,\%o;}
    return \@objects;
}
sub near {
    my ($a,$b)=@_;
    my $number=qr/\A[+-]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?\z/;
    return defined($a)&&defined($b)&&$a=~$number&&$b=~$number
        &&abs($a-$b)<=1e-10*max(1,abs($a),abs($b));
}
my %tables;
for my $name (@{$case->{files}}){
    die "Invalid manifest output path\n" unless $name =~ m{^[A-Za-z0-9_.-]+(?:/[A-Za-z0-9_.-]+)*$} && $name !~ m{(?:^|/)\.\.?(?:/|$)};
    my $path="$dir/$name";check(-s $path,"nonempty $name");
    if($name=~/\.csv\z/){$tables{$name}=csv(bytes($path));check(@{$tables{$name}}==$case->{expected_csv_rows}{$name},"$name expected row count");}
    if($name=~/\.png\z/){my $data=bytes($path);check(substr($data,0,8) eq "\x89PNG\r\n\x1a\n" && length($data)>24,"$name PNG signature");my ($w,$h)=unpack('NN',substr($data,16,8));check($w>0&&$h>0,"$name dimensions");}
    if($name=~/\.svg\z/){check(bytes($path)=~/<svg\b/,"$name SVG root");}
}
if($id eq 'hello'){
    my %names=map {$_->{name}=>1} @{$tables{'hello.csv'}};
    check(keys(%names)==19,'19 distinct SASHELP.CLASS teaching records');
}elsif($id eq 'clustergram'){
    my $input=csv(bytes("$Bin/inputs/poc261112_expression40.tsv"),"\t");
    my %scaled=map {$_->{gene}=>$_} @{$tables{'clustergram_2.csv'}};
    check(@$input==40 && keys(%scaled)==40,'40 genes');
    for my $row (@$input){my @tissues=sort grep {$_ ne 'gene'} keys %$row;
        check(@tissues==10,'ten tissues per gene');
        my @log=map {log(1+$row->{$_})/log(2)} @tissues;my $mean=sum(@log)/10;
        my $sd=sqrt(sum(map {($_-$mean)**2} @log)/9);
        check($sd>0,'nonconstant gene profile');
        for my $i (0..$#tissues){check(near($scaled{$row->{gene}}{$tissues[$i]},($log[$i]-$mean)/$sd),'independent log2 and sample-SD standardization');}
    }
}elsif($id eq 'gene_gtf'){
    my %transcripts=map {$_->{ensembl_transcript}=>1} grep {length($_->{ensembl_transcript}//'')} @{$tables{'gene_gtf_0.csv'}};
    check(keys(%transcripts)==3,'three transcript identifiers');
    for my $row (@{$tables{'gene_gtf_1.csv'}}){check($row->{chr}==2&&$row->{bp}>=72350000&&$row->{bp}<=72380000&&$row->{p}>0&&$row->{p}<=1,'GRCh37 regional input bounds and P range');}
}elsif($id eq 'oncoprint'){
    my $tiles=$tables{'oncoprint_0.csv'};my @callable=grep {$_->{callable}==1} @$tiles;
    check(@$tiles==96&&@callable==94,'96 gene-sample pairs and 94 assessable pairs');
    check(sum(map {$_->{n_variants}} @$tiles)==64,'64 synthetic event records');
    check(sum(map {$_->{n_events}} @{$tables{'oncoprint_2.csv'}})==64,'event-burden total');
    for my $row (@{$tables{'oncoprint_1.csv'}}){my @gene=grep {$_->{gene} eq $row->{gene}} @callable;my @mutated=grep {$_->{n_variants}>0} @gene;
        check(@gene==$row->{n_callable}&&@mutated==$row->{n_mutated}&&near(100*@mutated/@gene,$row->{pct_mutated}),'gene-specific assessable denominator and unique mutated pairs');}
}elsif($id eq 'forest'){
    for my $row (@{$tables{'forest_0.csv'}}){check(near($row->{beta},log($row->{odds_ratio}))&&near($row->{se},(log($row->{upper})-log($row->{lower}))/3.92),'log-OR and approximate SE reconstruction from rounded limits');}
}elsif($id eq 'multi_gwas_gtf'){
    my @missing=grep {$_->{ld_r2} eq '' || $_->{ld_r2} eq '.'} @{$tables{'regional_input.csv'}};
    check(@missing==10,'ten variants retain missing LD estimates');
    for my $row (@{$tables{'panel_values.csv'}}){
        check($row->{p}>0&&$row->{p}<=1&&near($row->{neglog10p},-log($row->{p})/log(10)),'independent association height');
        if($row->{ld_r2} eq ''||$row->{ld_r2} eq '.') {check($row->{signed_ld} eq ''||$row->{signed_ld} eq '.','missing numeric LD is not replaced by display fallback');}
        else{my $sign=$row->{z}<=>0;check(near($row->{signed_ld},$row->{ld_r2}*$sign),'signed LD arithmetic');}
    }
}
print "PASS: $checks file, row-count and numerical checks for $id.\n";
print "Inspect the complete SAS log and figure appearance separately; this is not full scientific validation.\n";
