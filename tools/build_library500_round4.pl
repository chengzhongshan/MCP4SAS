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
$destination //= "$Bin/../tests/library500_round4";
my @families;
sub family {push @families,{name=>$_[0],pattern=>$_[1],body=>$_[2],oracle=>$_[3],diagnostic=>$_[4]};}
my $means=qr/proc\s+(?:means|summary)/i;
my $uni=qr/proc\s+univariate/i;
my $corr=qr/proc\s+corr/i;
my $reg=qr/proc\s+reg\b/i;
my $glm=qr/proc\s+glm\b/i;
my $freq=qr/proc\s+freq/i;
family('means_sample_variance',$means,q{
data @P@a; do x=1 to @N@; output; end; run;
proc means data=@P@a noprint; var x; output out=@P@o var=actual; run;
},sub {$_[0]*($_[0]+1)/12});
family('means_population_variance',$means,q{
data @P@a; do x=1 to @N@; output; end; run;
proc means data=@P@a noprint vardef=n; var x; output out=@P@o var=actual; run;
},sub {($_[0]**2-1)/12});
family('means_standard_error',$means,q{
data @P@a; do x=1 to @N@; output; end; run;
proc means data=@P@a noprint; var x; output out=@P@o stderr=actual; run;
},sub {sqrt(($_[0]+1)/12)});
family('means_coefficient_variation',$means,q{
data @P@a; do x=1 to @N@; output; end; run;
proc means data=@P@a noprint; var x; output out=@P@o cv=actual; run;
},sub {100*sqrt($_[0]*($_[0]+1)/12)/(($_[0]+1)/2)});
family('means_sum_weights',$means,q{
data @P@a; do x=1 to @N@; weight=x; output; end; run;
proc means data=@P@a noprint; var x; weight weight; output out=@P@o sumwgt=actual; run;
},sub {$_[0]*($_[0]+1)/2});
family('means_freq_replication',$means,q{
data @P@a; do x=1 to @N@; reps=2; output; end; run;
proc means data=@P@a noprint; var x; freq reps; output out=@P@o var=actual; run;
},sub {my $n=shift; my $mean=($n+1)/2; my $ss=0; $ss+=2*($_-$mean)**2 for 1..$n; $ss/(2*$n-1)});
family('means_group_variances',$means,q{
data @P@a; do grp=1 to 2; do x=1 to @N@; y=grp*x; output; end; end; run;
proc means data=@P@a noprint nway; class grp; var y; output out=@P@b var=value; run;
proc sql; create table @P@o as select sum(value) as actual from @P@b; quit;
},sub {5*$_[0]*($_[0]+1)/12});
family('means_squared_range',$means,q{
data @P@a; do x=1 to @N@; y=x*x; output; end; run;
proc means data=@P@a noprint; var y; output out=@P@o range=actual; run;
},sub {$_[0]**2-1});
family('means_special_missing_counts',$means,q{
data @P@a; do x=0 to @N@; output; end; x=.A; output; x=.Z; output; run;
proc means data=@P@a noprint; var x; output out=@P@b n=valid nmiss=absent; run;
data @P@o; set @P@b; actual=10*valid+absent; run;
},sub {10*($_[0]+1)+2});
family('means_zero_weight_exclusion',$means,q{
data @P@a; do x=1 to @N@; weight=1; output; end; x=999; weight=0; output; run;
proc means data=@P@a noprint; var x; weight weight; output out=@P@o mean=actual; run;
},sub {($_[0]+1)/2});
family('univariate_odd_median',$uni,q{
data @P@a; do x=1 to 2*@N@+1; output; end; run;
proc univariate data=@P@a noprint; var x; output out=@P@o median=actual; run;
},sub {$_[0]+1});
family('univariate_quartile_def5',$uni,q{
data @P@a; do x=1 to 4*@N@; output; end; run;
proc univariate data=@P@a noprint pctldef=5; var x; output out=@P@b pctlpts=25 pctlpre=q; run;
data @P@o; set @P@b; actual=q25; run;
},sub {$_[0]+0.5});
family('univariate_interquartile_range',$uni,q{
data @P@a; do x=1 to 4*@N@; output; end; run;
proc univariate data=@P@a noprint; var x; output out=@P@o qrange=actual; run;
},sub {2*$_[0]});
family('univariate_symmetric_skewness',$uni,q{
data @P@a; do x=1 to 2*@N@+1; output; end; run;
proc univariate data=@P@a noprint; var x; output out=@P@o skewness=actual; run;
},sub {0});
family('univariate_uniform_kurtosis',$uni,q{
data @P@a; do x=1 to @N@+3; output; end; run;
proc univariate data=@P@a noprint; var x; output out=@P@o kurtosis=actual; run;
},sub {-1.2});
family('means_corrected_sum_squares',$means,q{
data @P@a; do x=1 to @N@; output; end; run;
proc means data=@P@a noprint; var x; output out=@P@o css=actual; run;
},sub {$_[0]*($_[0]**2-1)/12});
family('means_uncorrected_sum_squares',$means,q{
data @P@a; do x=1 to @N@; output; end; run;
proc means data=@P@a noprint; var x; output out=@P@o uss=actual; run;
},sub {$_[0]*($_[0]+1)*(2*$_[0]+1)/6});
family('corr_positive_affine',$corr,q{
data @P@a; do x=1 to @N@+2; y=@N@+3*x; output; end; run;
proc corr data=@P@a outp=@P@b noprint; var x y; run;
data @P@o; set @P@b; if _type_='CORR' and upcase(_name_)='X'; actual=y; run;
},sub {1});
family('corr_negative_affine',$corr,q{
data @P@a; do x=1 to @N@+2; y=@N@-3*x; output; end; run;
proc corr data=@P@a outp=@P@b noprint; var x y; run;
data @P@o; set @P@b; if _type_='CORR' and upcase(_name_)='X'; actual=y; run;
},sub {-1});
family('corr_spearman_tied_monotonic',$corr,q{
data @P@a; do x=1 to @N@; y=x*x; output; output; end; run;
proc corr data=@P@a outs=@P@b spearman noprint; var x y; run;
data @P@o; set @P@b; if _type_='CORR' and upcase(_name_)='X'; actual=y; run;
},sub {1});
family('corr_covariance',$corr,q{
data @P@a; do x=1 to @N@; y=3*x; output; end; run;
proc corr data=@P@a outp=@P@b cov noprint; var x y; run;
data @P@o; set @P@b; if _type_='COV' and upcase(_name_)='X'; actual=y; run;
},sub {$_[0]*($_[0]+1)/4});
family('corr_nomiss_listwise',$corr,q{
data @P@a; do x=1 to @N@; y=3*x; output; end; x=.; y=999; output; run;
proc corr data=@P@a outp=@P@b nomiss noprint; var x y; run;
data @P@o; set @P@b; if _type_='MEAN'; actual=y; run;
},sub {3*($_[0]+1)/2});
family('reg_intercept',$reg,q{
data @P@a; do x=1 to @N@+2; y=@N@+3*x; output; end; run;
proc reg data=@P@a outest=@P@b noprint; model y=x; quit;
data @P@o; set @P@b; if _type_='PARMS'; actual=intercept; run;
},sub {$_[0]});
family('reg_slope',$reg,q{
data @P@a; do x=1 to @N@+2; y=5+@NP1@*x; output; end; run;
proc reg data=@P@a outest=@P@b noprint; model y=x; quit;
data @P@o; set @P@b; if _type_='PARMS'; actual=x; run;
},sub {$_[0]+1});
family('reg_weighted_slope',$reg,q{
data @P@a; do x=1 to @N@+2; weight=x; y=5+@NP1@*x; output; end; run;
proc reg data=@P@a outest=@P@b noprint; model y=x; weight weight; quit;
data @P@o; set @P@b; if _type_='PARMS'; actual=x; run;
},sub {$_[0]+1});
family('reg_prediction',$reg,q{
data @P@a; do x=1 to @N@+2; y=2*x+@N@; output; end; run;
proc reg data=@P@a noprint; model y=x; output out=@P@b p=predicted; quit;
proc sql; create table @P@o as select max(abs(predicted-y)) as actual from @P@b; quit;
},sub {0});
family('glm_cell_means',$glm,q{
data @P@a; do grp=1 to 2; do x=1 to @N@; y=grp*x; output; end; end; run;
proc glm data=@P@a noprint; class grp; model y=grp; output out=@P@b p=predicted; quit;
proc sql; create table @P@c as select grp,mean(predicted) as pred from @P@b group by grp;
create table @P@o as select sum(pred) as actual from @P@c; quit;
},sub {3*($_[0]+1)/2});
family('glm_residual_squares',$glm,q{
data @P@a; do grp=1 to 2; do x=1 to @N@; y=grp*x; output; end; end; run;
proc glm data=@P@a noprint; class grp; model y=grp; output out=@P@b r=residual; quit;
proc sql; create table @P@o as select sum(residual*residual) as actual from @P@b; quit;
},sub {5*$_[0]*($_[0]**2-1)/12});
family('glm_class_covariate_exact',$glm,q{
data @P@a; do grp=1 to 2; do x=1 to @N@; y=10*grp+2*x; output; end; end; run;
proc glm data=@P@a noprint; class grp; model y=grp x; output out=@P@b r=residual; quit;
proc sql; create table @P@o as select max(abs(residual)) as actual from @P@b; quit;
},sub {0});
family('freq_uniform_percent',$freq,q{
data @P@a; do k=1 to @N@; output; end; run;
proc freq data=@P@a noprint; tables k / out=@P@b; run;
proc sql; create table @P@o as select max(percent) as actual from @P@b; quit;
},sub {100/$_[0]});
family('freq_row_percent',$freq,q{
data @P@a; do grp=1 to 2; do k=1 to @N@; output; end; end; run;
proc freq data=@P@a noprint; tables grp*k / out=@P@b outpct; run;
proc sql; create table @P@o as select max(pct_row) as actual from @P@b; quit;
},sub {100/$_[0]});
family('freq_sparse_cells',$freq,q{
data @P@a; do a=1 to @N@; b=a; output; end; run;
proc freq data=@P@a noprint; tables a*b / sparse out=@P@b; run;
proc sql; create table @P@o as select sum(count=0) as actual from @P@b; quit;
},sub {$_[0]*($_[0]-1)});
family('freq_weighted_cumulative',$freq,q{
data @P@a; do k=1 to @N@; weight=k; output; end; run;
proc freq data=@P@a noprint; tables k / out=@P@b outcum; weight weight; run;
proc sql; create table @P@o as select sum(cum_freq) as actual from @P@b; quit;
},sub {$_[0]*($_[0]+1)*($_[0]+2)/6});
family('rank_groups_balanced',qr/proc\s+rank/i,q{
data @P@a; do x=1 to 2*@N@; output; end; run;
proc rank data=@P@a out=@P@b groups=2; var x; ranks bin; run;
proc sql; create table @P@o as select sum(bin) as actual from @P@b; quit;
},sub {$_[0]});
family('standard_unit_variance',qr/proc\s+standard\b/i,q{
data @P@a; do x=1 to @N@+2; output; end; run;
proc standard data=@P@a out=@P@b mean=0 std=1; var x; run;
proc means data=@P@b noprint; var x; output out=@P@c mean=center var=variance; run;
data @P@o; set @P@c; actual=abs(center)+variance; run;
},sub {1});
family('rank_dense_ties',qr/proc\s+rank/i,q{
data @P@a; do x=1 to @N@; output; output; end; run;
proc rank data=@P@a out=@P@b ties=dense; var x; ranks position; run;
proc sql; create table @P@o as select max(position) as actual from @P@b; quit;
},sub {$_[0]});
family('summary_complete_types',$means,q{
data @P@a; do a=1 to @N@; b=a; x=1; output; end; run;
proc summary data=@P@a nway completetypes; class a b; var x; output out=@P@b sum=total; run;
proc sql; create table @P@o as select sum(_freq_=0) as actual from @P@b; quit;
},sub {$_[0]*($_[0]-1)});
family('summary_marginal_types',$means,q{
data @P@a; do a=1 to @N@; do b=1 to 2; x=1; output; end; end; run;
proc summary data=@P@a; class a b; types a b; var x; output out=@P@b sum=total; run;
proc sql; create table @P@o as select sum(_freq_) as actual from @P@b; quit;
},sub {4*$_[0]});
family('sql_population_covariance',qr/proc\s+sql/i,q{
data @P@a; do x=1 to @N@; y=3*x; output; end; run;
proc sql; create table @P@o as select mean(x*y)-mean(x)*mean(y) as actual from @P@a; quit;
},sub {($_[0]**2-1)/4});
family('sql_standard_error',qr/proc\s+sql/i,q{
data @P@a; do x=1 to @N@; output; end; run;
proc sql; create table @P@o as select stderr(x) as actual from @P@a; quit;
},sub {sqrt(($_[0]+1)/12)});
family('sql_missing_weighted_denominator',qr/proc\s+sql/i,q{
data @P@a; do x=1 to @N@+2; if mod(x,2)=0 then y=x; else y=.; output; end; run;
proc sql; create table @P@o as select sum(y*x)/sum(case when y is not missing then x else 0 end) as actual from @P@a; quit;
},sub {my $n=shift; my ($num,$den)=(0,0); for (1..$n+2) {next if $_%2; $num+=$_*$_; $den+=$_;} $num/$den});
family('transpose_wide_long_checksum',qr/proc\s+transpose/i,q{
data @P@a; do k=1 to @N@; value=k*k; output; end; run;
proc transpose data=@P@a out=@P@b prefix=v; id k; var value; run;
proc transpose data=@P@b(drop=_name_) out=@P@c prefix=back; var v1-v@N@; run;
proc sql; create table @P@o as select sum(back1) as actual from @P@c; quit;
},sub {$_[0]*($_[0]+1)*(2*$_[0]+1)/6});
family('frequency_row_expansion',qr/\boutput\b/i,q{
data @P@a; do k=1 to @N@; freq=k; output; end; run;
data @P@b; set @P@a; do rep=1 to freq; output; end; run;
proc sql; create table @P@o as select sum(k) as actual from @P@b; quit;
},sub {$_[0]*($_[0]+1)*(2*$_[0]+1)/6});
family('online_welford_variance',qr/\bretain\b/i,q{
data @P@a; do x=1 to @N@; output; end; run;
data @P@o; set @P@a end=last; retain count 0 center 0 m2 0; count+1; delta=x-center; center=center+delta/count; m2=m2+delta*(x-center); if last; actual=m2/(count-1); run;
},sub {$_[0]*($_[0]+1)/12});
family('array_row_standardization',qr/\barray\b/i,q{
data @P@o; array x[3] x1-x3 (@N@ @NX2@ @NX3@); center=mean(of x[*]); spread=std(of x[*]); actual=0; do j=1 to dim(x); actual=actual+((x[j]-center)/spread)**2; end; run;
},sub {2});
# These last five families must fail in SAS. They run one case per job and
# require both nonzero CLI status and a matching runtime ERROR diagnostic.
family('failure_reg_missing_response',$reg,q{
data @P@a; do x=1 to @N@+2; y=x; output; end; run;
proc reg data=@P@a noprint; model @P@absent=x; quit;
},undef,'(?:not found|does not exist)');
family('failure_freq_character_weight',$freq,q{
data @P@a; length weight $8; do x=1 to @N@; weight='@N@'; output; end; run;
proc freq data=@P@a; tables x; weight weight; run;
},undef,'(?:weight|type|numeric)');
family('failure_append_type_mismatch',qr/proc\s+append/i,q{
data @P@a; value=@N@; run;
data @P@b; length value $12; value='@N@'; run;
proc append base=@P@a data=@P@b; run;
},undef,'(?:type|character|numeric|appending|anomal)');
family('failure_means_missing_variable',$means,q{
data @P@a; do x=1 to @N@; output; end; run;
proc means data=@P@a; var @P@absent; run;
},undef,'(?:not found|does not exist)');
family('failure_sql_ambiguous_column',qr/proc\s+sql/i,q{
data @P@a; x=@N@; run; data @P@b; x=@NP1@; run;
proc sql; create table @P@o as select x from @P@a a,@P@b b; quit;
},undef,'ambiguous');
die 'Expected 50 families' unless @families==50;
my @files;
for my $sub (qw(Easy-For-Error-Codes-SAS SAS_Code_Database Macros)) {
    my $dir="$library/SAS-Useful-Codes/$sub"; die "Missing $dir" unless -d $dir;
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
die 'Missing evidence: '.join(',',map {$_->{name}} grep {!$_->{evidence}} @families)."\n" if grep {!$_->{evidence}} @families;
make_path($destination);
my (@cases,%seen);
for my $family (@families) {
    for my $n (2..11) {
        my $id=sprintf 'F%04d',1501+@cases; my $prefix=lc $id; my $body=$family->{body};
        my %replace=('@P@'=>$prefix,'@N@'=>$n,'@NP1@'=>$n+1,'@NX2@'=>2*$n,'@NX3@'=>3*$n);
        $body=~s/(\@(?:P|N|NP1|NX2|NX3)\@)/$replace{$1}/ge;
        my $negative=defined $family->{diagnostic};
        my $expected=$negative?undef:$family->{oracle}->($n);
        my $assert=$negative?'':"data _null_; if 0 then set ${prefix}o nobs=rows;\nif rows ne 1 then put 'ERROR: ROUND4_ROWS=$id rows=' rows;\n"
            ."else do; set ${prefix}o; if not missing(actual) and abs(actual-($expected))<=1e-9*max(1,abs($expected)) then put 'ROUND4_PASS=$id';\n"
            ."else put 'ERROR: ROUND4_FAIL=$id actual=' actual; end; stop; run;\n";
        my $source="/* $id $family->{name}, N=$n; source: $family->{evidence}{path}:$family->{evidence}{line} */\n$body\n$assert"
            ."proc datasets library=work nolist; delete ${prefix}:; quit;\n";
        my $canonical=$source; $canonical=~s{\A/\*[^\n]*\*/\n}{}; $canonical=~s/f\d{4}/fCASE/ig;
        my $fingerprint=sha256_hex($canonical); die "Duplicate $id" if $seen{$fingerprint}++;
        open my $out,'>:raw',"$destination/$id.sas" or die $!; print {$out} $source; close $out or die $!;
        push @cases,{id=>$id,file=>"$id.sas",family=>$family->{name},input_n=>$n,expected=>$expected,
            expected_failure=>$negative?JSON::PP::true:JSON::PP::false,diagnostic=>$family->{diagnostic},
            body_sha256=>$fingerprint,evidence=>$family->{evidence},tables_prefix=>$prefix};
    }
}
open my $mf,'>:raw',"$destination/manifest.json" or die $!;
print {$mf} JSON::PP->new->canonical->pretty->encode({schema=>1,count=>500,round=>4,success_cases=>450,expected_failure_cases=>50,
    description=>'45 statistical/transformation families and five intentional SAS failure families; ten scenarios each',cases=>\@cases});
close $mf or die $!;
print "Wrote ".scalar(@cases)." fourth-round SAS evaluations to $destination\n";
