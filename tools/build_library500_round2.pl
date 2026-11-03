#!/usr/bin/env perl
use strict; use warnings;
use FindBin qw($Bin);
use File::Find qw(find);
use File::Spec;
use File::Path qw(make_path);
use Digest::SHA qw(sha256_hex);
use JSON::PP;

my ($library,$destination)=@ARGV;
die "Usage: $0 SASCodesLibrary [OUTPUT_DIRECTORY]\n" unless defined $library && -d $library;
$destination //= "$Bin/../tests/library500_round2";
my @families;
sub family {push @families,{name=>$_[0],pattern=>$_[1],body=>$_[2],oracle=>$_[3]};}
# Each oracle is calculated from the synthetic input in Perl, never from SAS.
family('sql_count_distinct',qr/count\s*\(\s*distinct/i,q{
data @P@a; do k=1 to @N@; output; output; end; run;
proc sql; create table @P@o as select count(distinct k) as actual from @P@a; quit;
},sub {$_[0]});
family('sql_group_having',qr/\bhaving\b/i,q{
data @P@a; do k=1 to @N@; do j=1 to k; output; end; end; run;
proc sql; create table @P@b as select k,count(*) as cnt from @P@a group by k having count(*)>1;
create table @P@o as select sum(cnt) as actual from @P@b; quit;
},sub {$_[0]*($_[0]+1)/2-1});
family('sql_inner_multiplicity',qr/inner\s+join/i,q{
data @P@a; do k=1 to @N@; output; output; end; run;
data @P@b; do k=1 to @N@; do j=1 to 3; output; end; end; run;
proc sql; create table @P@o as select count(*) as actual from @P@a a inner join @P@b b on a.k=b.k; quit;
},sub {6*$_[0]});
family('sql_left_anti',qr/left\s+join/i,q{
data @P@a; do k=1 to 2*@N@; output; end; run;
data @P@b; do k=2 to 2*@N@ by 2; output; end; run;
proc sql; create table @P@o as select sum(a.k) as actual from @P@a a left join @P@b b on a.k=b.k where b.k is missing; quit;
},sub {$_[0]**2});
family('sql_full_keys',qr/full\s+join/i,q{
data @P@a; do k=1 to @N@; output; end; run;
data @P@b; do k=@N@ to 2*@N@; output; end; run;
proc sql; create table @P@o as select count(coalesce(a.k,b.k)) as actual from @P@a a full join @P@b b on a.k=b.k; quit;
},sub {2*$_[0]});
family('sql_union',qr/\bunion\b/i,q{
data @P@a; do x=1 to @N@; output; end; run;
data @P@b; do x=@N@ to 2*@N@; output; end; run;
proc sql; create table @P@c as select x from @P@a union select x from @P@b;
create table @P@o as select sum(x) as actual from @P@c; quit;
},sub {$_[0]*(2*$_[0]+1)});
family('sql_union_all',qr/union\s+all/i,q{
data @P@a; do x=1 to @N@; output; end; run;
proc sql; create table @P@c as select x from @P@a union all select x from @P@a;
create table @P@o as select sum(x) as actual from @P@c; quit;
},sub {$_[0]*($_[0]+1)});
family('sql_except',qr/\bexcept\b/i,q{
data @P@a; do x=1 to 2*@N@; output; end; run;
data @P@b; do x=2 to 2*@N@ by 2; output; end; run;
proc sql; create table @P@c as select x from @P@a except select x from @P@b;
create table @P@o as select sum(x) as actual from @P@c; quit;
},sub {$_[0]**2});
family('sql_intersect',qr/\bintersect\b/i,q{
data @P@a; do x=1 to 2*@N@; output; end; run;
data @P@b; do x=@N@ to 3*@N@; output; end; run;
proc sql; create table @P@c as select x from @P@a intersect select x from @P@b;
create table @P@o as select sum(x) as actual from @P@c; quit;
},sub {3*$_[0]*($_[0]+1)/2});
family('sql_case',qr/case\s+when/i,q{
data @P@a; do x=-@N@ to @N@; output; end; run;
proc sql; create table @P@o as select sum(case when x<0 then -2*x else x end) as actual from @P@a; quit;
},sub {3*$_[0]*($_[0]+1)/2});
family('sql_exists',qr/\bexists\s*\(/i,q{
data @P@a; do k=1 to 2*@N@; output; end; run;
data @P@b; do k=1 to @N@; output; output; end; run;
proc sql; create table @P@o as select sum(k) as actual from @P@a a where exists(select * from @P@b b where b.k=a.k); quit;
},sub {$_[0]*($_[0]+1)/2});
family('sql_not_exists',qr/not\s+exists/i,q{
data @P@a; do k=1 to 2*@N@; output; end; run;
data @P@b; do k=1 to @N@; output; end; run;
proc sql; create table @P@o as select sum(k) as actual from @P@a a where not exists(select * from @P@b b where b.k=a.k); quit;
},sub {$_[0]*(3*$_[0]+1)/2});
family('sql_correlated_max',qr/select\s+max\s*\(/i,q{
data @P@a; do k=1 to @N@; do v=1 to k; output; end; end; run;
proc sql; create table @P@o as select sum(v) as actual from @P@a a where v=(select max(v) from @P@a b where a.k=b.k); quit;
},sub {$_[0]*($_[0]+1)/2});
family('sql_calculated',qr/\bcalculated\b/i,q{
data @P@a; do x=1 to @N@; output; end; run;
proc sql; create table @P@b as select x,2*x as doubled,calculated doubled+1 as y from @P@a;
create table @P@o as select sum(y) as actual from @P@b; quit;
},sub {$_[0]*($_[0]+2)});
family('sql_update',qr/\bupdate\s+\w+/i,q{
data @P@a; do x=1 to @N@; value=x; output; end; run;
proc sql; update @P@a set value=value+10 where mod(x,2)=0;
create table @P@o as select sum(value) as actual from @P@a; quit;
},sub {$_[0]*($_[0]+1)/2+10*int($_[0]/2)});
family('sql_delete',qr/delete\s+from/i,q{
data @P@a; do x=1 to 2*@N@; output; end; run;
proc sql; delete from @P@a where x<=@N@;
create table @P@o as select sum(x) as actual from @P@a; quit;
},sub {$_[0]*(3*$_[0]+1)/2});
family('sql_insert',qr/insert\s+into/i,q{
data @P@a; x=0; output; run;
data @P@b; do x=1 to @N@; output; end; run;
proc sql; insert into @P@a select x from @P@b;
create table @P@o as select sum(x)+count(*) as actual from @P@a; quit;
},sub {$_[0]*($_[0]+1)/2+$_[0]+1});
family('sort_nodupkey',qr/\bnodupkey\b/i,q{
data @P@a; do k=@N@ to 1 by -1; value=k; output; value=999; output; end; run;
proc sort data=@P@a out=@P@b nodupkey equals; by k; run;
proc sql; create table @P@o as select sum(value) as actual from @P@b; quit;
},sub {$_[0]*($_[0]+1)/2});
family('sort_descending',qr/descending\b/i,q{
data @P@a; do x=1 to @N@; output; end; run;
proc sort data=@P@a out=@P@b; by descending x; run;
data @P@o; set @P@b; if _n_=1; actual=x; run;
},sub {$_[0]});
family('by_group_total',qr/first\.[A-Za-z_]/i,q{
data @P@a; do k=1 to @N@; do x=1 to k; output; end; end; run;
data @P@b; set @P@a; by k; if first.k then total=0; total+x; if last.k; run;
proc sql; create table @P@o as select sum(total) as actual from @P@b; quit;
},sub {$_[0]*($_[0]+1)*($_[0]+2)/6});
family('retain_product',qr/\bretain\b/i,q{
data @P@a; do x=1 to @N@; output; end; run;
data @P@o; set @P@a end=last; retain product 1; product=product*x; if last; actual=product; run;
},sub {my $p=1; $p*=$_ for 1..$_[0]; $p});
family('sum_statement_missing',qr/\bretain\b/i,q{
data @P@a; do j=1 to @N@; x=j; output; x=.; output; end; run;
data @P@o; set @P@a end=last; total+x; if last; actual=total; run;
},sub {$_[0]*($_[0]+1)/2});
family('lag_queue',qr/\blag\s*\(/i,q{
data @P@a; do x=1 to @N@; value=x*x; output; end; run;
data @P@b; set @P@a; prev=lag(value); delta=value-prev; run;
proc sql; create table @P@o as select sum(delta) as actual from @P@b; quit;
},sub {$_[0]**2-1});
family('dif_series',qr/\bdif\s*\(/i,q{
data @P@a; do x=1 to @N@; value=x*x*x; output; end; run;
data @P@b; set @P@a; delta=dif(value); run;
proc sql; create table @P@o as select sum(delta) as actual from @P@b; quit;
},sub {$_[0]**3-1});
family('point_reverse',qr/\bpoint\s*=/i,q{
data @P@a; do x=1 to @N@; output; end; run;
data @P@b; do ptr=@N@ to 1 by -1; set @P@a point=ptr; weight=@N@-ptr+1; value=weight*x; output; end; stop; run;
proc sql; create table @P@o as select sum(value) as actual from @P@b; quit;
},sub {$_[0]*($_[0]+1)*($_[0]+2)/6});
family('nobs_metadata',qr/\bnobs\s*=/i,q{
data @P@a; do x=1 to @N@; output; end; run;
data @P@o; if 0 then set @P@a nobs=number; actual=number; output; stop; run;
},sub {$_[0]});
family('array_shift',qr/\barray\b/i,q{
data @P@o; array v[4] x1-x4 (@N@ 2 3 4); do j=4 to 2 by -1; v[j]=v[j-1]; end; v[1]=0; actual=x1+2*x2+3*x3+4*x4; run;
},sub {2*$_[0]+18});
family('transpose_roundtrip',qr/proc\s+transpose/i,q{
data @P@a; do k=1 to @N@; do visit=1 to 2; value=10*k+visit; output; end; end; run;
proc transpose data=@P@a out=@P@b prefix=v; by k; id visit; var value; run;
proc sql; create table @P@o as select sum(v2-v1) as actual from @P@b; quit;
},sub {$_[0]});
family('summary_weighted',qr/proc\s+(?:summary|means)/i,q{
data @P@a; do x=1 to @N@; weight=x; output; end; run;
proc summary data=@P@a; var x; weight weight; output out=@P@b mean=average; run;
data @P@o; set @P@b; actual=average; run;
},sub {(2*$_[0]+1)/3});
family('rank_ties',qr/proc\s+rank/i,q{
data @P@a; do x=1 to @N@; output; output; end; run;
proc rank data=@P@a out=@P@b ties=mean; var x; ranks position; run;
proc sql; create table @P@o as select sum(position) as actual from @P@b; quit;
},sub {$_[0]*(2*$_[0]+1)});
family('freq_counts',qr/proc\s+freq/i,q{
data @P@a; do k=1 to @N@; do j=1 to k; output; end; end; run;
proc freq data=@P@a noprint; tables k / out=@P@b; run;
proc sql; create table @P@o as select sum(count) as actual from @P@b; quit;
},sub {$_[0]*($_[0]+1)/2});
family('compare_equal',qr/proc\s+compare/i,q{
data @P@a; do x=1 to @N@; value=x*x; output; end; run;
data @P@b; set @P@a; run;
proc compare base=@P@a compare=@P@b noprint; run;
data @P@o; actual=&sysinfo; run;
},sub {0});
family('hash_lookup',qr/\b(?:declare|dcl)\s+hash/i,q{
data @P@a; do k=1 to @N@; value=3*k; output; end; run;
data @P@b; if 0 then set @P@a; declare hash h(dataset:'@P@a'); h.definekey('k'); h.definedata('value'); h.definedone();
do k=1 to @N@; rc=h.find(); if rc=0 then output; end; stop; run;
proc sql; create table @P@o as select sum(value) as actual from @P@b; quit;
},sub {3*$_[0]*($_[0]+1)/2});
family('resolve_macro_expression',qr/\bresolve\s*\(/i,q{
%macro r@ID@m(); %eval(@N@*11) %mend;
data @P@o; actual=input(resolve('%r@ID@m()'),best32.); run;
%sysmacdelete r@ID@m;
},sub {11*$_[0]});
family('merge_in_flags',qr/\bmerge\b/i,q{
data @P@a; do k=1 to @N@; output; end; run;
data @P@b; do k=@N@ to 2*@N@; output; end; run;
data @P@c; merge @P@a(in=ina) @P@b(in=inb); by k; if ina and not inb; run;
proc sql; create table @P@o as select sum(k) as actual from @P@c; quit;
},sub {$_[0]*($_[0]-1)/2});
family('set_end_flag',qr/\bend\s*=/i,q{
data @P@a; do x=1 to @N@; output; end; run;
data @P@b; do x=1 to @N@+1; output; end; run;
data @P@o; set @P@a @P@b end=last; if last; actual=_n_; run;
},sub {2*$_[0]+1});
family('dsd_empty_fields',qr/\bdsd\b/i,q{
filename rtemp temp;
data _null_; file rtemp; put '@N@,,3'; run;
data @P@o; infile rtemp dsd dlm=','; input a b c; actual=a+c+100*missing(b); run;
filename rtemp clear;
},sub {$_[0]+103});
family('dsd_quoted_delimiter',qr/\bdsd\b/i,q{
filename rtemp temp;
data _null_; file rtemp; put '"a,b",@N@'; run;
data @P@o; length text $8; infile rtemp dsd dlm=','; input text :$8. n; actual=n+100*(text='a,b'); run;
filename rtemp clear;
},sub {$_[0]+100});
family('truncover_short_record',qr/\btruncover\b/i,q{
filename rtemp temp;
data _null_; file rtemp; put '@N@'; run;
data @P@o; infile rtemp truncover; input a 1-2 b 4-6; actual=a+100*missing(b); run;
filename rtemp clear;
},sub {$_[0]+100});
family('scanover_anchor',qr/\bscanover\b/i,q{
filename rtemp temp;
data _null_; file rtemp; put 'junk'; put 'score=@N@'; run;
data @P@o; infile rtemp scanover; input @'score=' n; actual=n; run;
filename rtemp clear;
},sub {$_[0]});
family('input_double_at',qr/@@/i,q{
data @P@a; input value @@; datalines;
@N@ @NP1@ @NP2@
;
run;
proc sql; create table @P@o as select sum(value) as actual from @P@a; quit;
},sub {3*$_[0]+3});
family('input_colon_modifier',qr/:\s*\$\w*\d+\./i,q{
data @P@a; input label :$20. value; datalines;
alpha @N@
beta @NP1@
;
run;
proc sql; create table @P@o as select sum(value)+count(distinct label) as actual from @P@a; quit;
},sub {2*$_[0]+3});
family('input_ampersand',qr/\binput\b.*&/i,q{
data @P@o; input label & $20. value; actual=value+100*(label='New York'); datalines;
New York  @N@
;
run;
},sub {$_[0]+100});
family('cards4_literal_source',qr/\b(?:cards4|datalines4)\b/i,q{
data @P@a; infile datalines4 truncover; input text $char100.; datalines4;
%include 'absent_@N@.sas'; /*
plain_@N@
;;;;
run;
proc sql; create table @P@o as select sum(lengthn(text)) as actual from @P@a; quit;
},sub {length("%include 'absent_$_[0].sas'; /*")+length("plain_$_[0]")});
family('temporary_file_roundtrip',qr/\bfilename\b.*\btemp\b/i,q{
filename rtemp temp;
data _null_; file rtemp; do x=1 to @N@; put x; end; run;
data @P@a; infile rtemp; input x; run;
filename rtemp clear;
proc sql; create table @P@o as select sum(x) as actual from @P@a; quit;
},sub {$_[0]*($_[0]+1)/2});
family('macro_local_scope',qr/%local\b/i,q{
%let r@ID@v=77;
%macro r@ID@m(); %local r@ID@v; %let r@ID@v=@N@;
data @P@a; inner=&r@ID@v; run;
%mend; %r@ID@m();
data @P@o; set @P@a; actual=inner+&r@ID@v; run;
%symdel r@ID@v; %sysmacdelete r@ID@m;
},sub {$_[0]+77});
family('call_execute_deferred',qr/call\s+execute/i,q{
data _null_; call execute('data @P@a; do x=1 to @N@; output; end; run;'); run;
proc sql; create table @P@o as select sum(x*x) as actual from @P@a; quit;
},sub {$_[0]*($_[0]+1)*(2*$_[0]+1)/6});
family('dosubl_synchronous',qr/\bdosubl\s*\(/i,q{
data @P@o; rc=dosubl('data @P@a; do x=1 to @N@; output; end; run;');
dsid=open('@P@a','i'); if dsid>0 then do; actual=attrn(dsid,'NLOBS'); rc=close(dsid); end; output; stop; run;
},sub {$_[0]});
family('dictionary_column_types',qr/dictionary\.columns/i,q{
data @P@a; length label $@N@; array v[@N@] x1-x@N@; do j=1 to @N@; v[j]=j; end; drop j; run;
proc sql; create table @P@o as select sum(type='num') as actual from dictionary.columns where libname='WORK' and memname=upcase('@P@a'); quit;
},sub {$_[0]});
family('fileref_include',qr/%include\b/i,q{
filename rtemp temp;
data _null_; file rtemp; put 'data @P@o; actual=@N@*7; run;'; run;
%include rtemp;
filename rtemp clear;
},sub {7*$_[0]});
die 'Expected 50 behavior families' unless @families==50;

my @files;
for my $sub (qw(Easy-For-Error-Codes-SAS SAS_Code_Database Macros)) {
    my $dir="$library/SAS-Useful-Codes/$sub";
    die "Missing $dir" unless -d $dir;
    find({no_chdir=>1,wanted=>sub {push @files,$File::Find::name if -f $_ && /\.sas$/i}},$dir);
}
for my $path (sort @files) {
    open my $fh,'<:raw',$path or die "$path: $!"; local $/; my $source=<$fh>; close $fh;
    my $line=0;
    for my $text (split /\n/,$source) {
        ++$line;
        for my $family (@families) {
            next if $family->{evidence};
            if ($text =~ $family->{pattern}) {
                my $relative=File::Spec->abs2rel($path,$library); $relative=~s{\\}{/}g;
                $family->{evidence}={path=>$relative,line=>$line,source_sha256=>sha256_hex($source),evidence_sha256=>sha256_hex($text)};
            }
        }
    }
    last unless grep {!$_->{evidence}} @families;
}
my @missing=grep {!$_->{evidence}} @families;
die 'Missing source evidence: '.join(',',map {$_->{name}} @missing)."\n" if @missing;
make_path($destination);
my (@cases,%seen);
for my $family (@families) {
    for my $n (2..11) {
        my $id=sprintf 'R%03d',501+@cases;
        my $prefix=lc $id;
        my $body=$family->{body};
        my %replace=('@P@'=>$prefix,'@ID@'=>substr($id,1),'@N@'=>$n,'@NP1@'=>$n+1,'@NP2@'=>$n+2);
        $body=~s/(\@(?:P|ID|N|NP1|NP2)\@)/$replace{$1}/ge;
        $body=~s/\bresolve\(/RESOLVE(/g if $family->{name} eq 'resolve_macro_expression' && $n%2==0;
        my $expected=$family->{oracle}->($n);
        my $source="/* $id $family->{name}, N=$n; source: $family->{evidence}{path}:$family->{evidence}{line} */\n$body\n"
            ."data _null_; if 0 then set ${prefix}o nobs=rows;\n"
            ."if rows ne 1 then put 'ERROR: ROUND2_ROWS=$id rows=' rows;\n"
            ."else do; set ${prefix}o; if not missing(actual) and abs(actual-($expected))<=1e-10*max(1,abs($expected)) then put 'ROUND2_PASS=$id';\n"
            ."else put 'ERROR: ROUND2_FAIL=$id actual=' actual; end; stop; run;\n"
            ."proc datasets library=work nolist; delete ${prefix}:; quit;\n";
        my $canonical=$source; $canonical=~s{\A/\*[^\n]*\*/\n}{}; $canonical=~s/r\d{3,4}/rCASE/ig;
        my $fingerprint=sha256_hex($canonical);
        die "ID-only duplicate $id" if $seen{$fingerprint}++;
        open my $out,'>:raw',"$destination/$id.sas" or die $!; print {$out} $source; close $out or die $!;
        push @cases,{id=>$id,file=>"$id.sas",family=>$family->{name},input_n=>$n,expected=>$expected,
            body_sha256=>$fingerprint,evidence=>$family->{evidence},tables_prefix=>$prefix};
    }
}
open my $mf,'>:raw',"$destination/manifest.json" or die $!;
print {$mf} JSON::PP->new->canonical->pretty->encode({schema=>1,count=>500,round=>2,
    description=>'50 relational, dataset, input/output and macro families, ten synthetic input sizes each',cases=>\@cases});
close $mf or die $!;
print "Wrote ".scalar(@cases)." new runnable SAS scripts to $destination\n";
