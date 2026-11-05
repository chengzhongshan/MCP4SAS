#!/usr/bin/env perl
use strict; use warnings; use FindBin qw($Bin); use lib "$Bin/lib"; use Library_Evaluation_Corpus;
my ($books,$destination)=@ARGV;
die "Usage: $0 BOOK_SAMPLE_DIRECTORY [OUTPUT_DIRECTORY]\n" unless defined $books && -d $books;
$destination //= "$Bin/../tests/library500_round10";
my @families; my $base=qr/Programming|Data Cleaning|Combining|Little SAS Book/i;
sub family {push @families,{name=>$_[0],pattern=>$_[1],body=>$_[2],oracle=>$_[3],diagnostic=>$_[4],book_pattern=>$_[5]//$base,tolerance=>$_[6]//'1e-9'};}
sub factorial {my $x=1; $x*=$_ for 1..$_[0]; $x;}
my @probability=(
 ['normal_density_location',q{pdf('normal',@N@,@N@,2)},sub {1/(2*sqrt(8*atan2(1,1)))}],
 ['normal_cdf_location',q{cdf('normal',@N@,@N@,3)},sub {0.5}],
 ['normal_complement_symmetry',q{cdf('normal',@N@/10)+cdf('normal',-@N@/10)},sub {1}],
 ['normal_quantile_location',q{quantile('normal',0.5,@N@,2)},sub {$_[0]}],
 ['exponential_scale_cdf',q{cdf('exponential',@N@,@N@)},sub {1-exp(-1)}],
 ['exponential_scale_quantile',q{quantile('exponential',1-exp(-1),@N@)},sub {$_[0]}],
 ['uniform_midpoint_cdf',q{cdf('uniform',@N@,0,2*@N@)},sub {0.5}],
 ['uniform_quartile_location',q{quantile('uniform',0.25,@N@,5*@N@)},sub {2*$_[0]}],
 ['binomial_zero_cdf',q{cdf('binomial',0,0.25,@N@)},sub {0.75**$_[0]}],
 ['binomial_one_density',q{pdf('binomial',1,0.25,@N@)},sub {$_[0]*0.25*0.75**($_[0]-1)}],
 ['poisson_zero_density',q{pdf('poisson',0,@N@)},sub {exp(-$_[0])}],
 ['poisson_one_cdf',q{cdf('poisson',1,@N@)},sub {exp(-$_[0])*(1+$_[0])}],
 ['geometric_zero_failures',q{pdf('geometric',0,1/(@N@+1))},sub {1/($_[0]+1)}],
 ['gamma_shape_one_cdf',q{cdf('gamma',@N@,1,@N@)},sub {1-exp(-1)}],
 ['chisquare_two_df_cdf',q{cdf('chisquare',2*@N@,2)},sub {1-exp(-$_[0])}],
 ['log_gamma_integer_factorial',q{lgamma(@N@+1)},sub {log(factorial($_[0]))}],
 ['beta_integer_symmetry',q{beta(@N@,@N@)},sub {factorial($_[0]-1)**2/factorial(2*$_[0]-1)}],
 ['logistic_location_cdf',q{cdf('logistic',@N@,@N@,2)},sub {0.5}],
 ['weibull_unit_scale_ratio',q{cdf('weibull',@N@,2,@N@)},sub {1-exp(-1)}],
 ['student_t_center_cdf',q{cdf('t',0,@N@)},sub {0.5}],
);
for my $p (@probability) {
 family($p->[0],qr/\b(?:probnorm|probit)\s*\(/i,"data \@P\@o; actual=$p->[1]; run;\n",$p->[2],undef,qr/Statistical|Statistics|Clinical|Meta-Analytic|Multivariate/i,'1e-10');
 $families[-1]{derived_extension}=1;
}
family('matrix_filter_before_transpose',qr/^\s*array\b/i,q{
data @P@a; length gene $12; array expr{*} v1-v@N@; do g=1 to 3; gene=cats('gene',g); do j=1 to dim(expr); expr{j}=g*j; end; output; end; drop j g; run;
data @P@b; set @P@a(where=(gene in ('gene1','gene2'))); array expr{*} v1-v@N@; do sample=1 to dim(expr); value=expr{sample}; output; end; keep gene sample value; run;
proc sql; create table @P@o as select count(*) as actual from @P@b; quit;
},sub {2*$_[0]},undef,qr/Combining/i);
family('matrix_selected_gene_checksum',qr/^\s*array\b/i,q{
data @P@a; length gene $12; array expr{*} v1-v@N@; do g=1 to 3; gene=cats('gene',g); do j=1 to dim(expr); expr{j}=g*j; end; output; end; drop j g; run;
data @P@b; set @P@a(where=(gene='gene2')); array expr{*} v1-v@N@; do sample=1 to dim(expr); value=expr{sample}; output; end; keep sample value; run;
proc sql; create table @P@o as select sum(value) as actual from @P@b; quit;
},sub {$_[0]*($_[0]+1)},undef,qr/Combining/i);
family('matrix_prefix_excludes_numeric_metadata',qr/^\s*array\b/i,q{
data @P@o; metadata=100000; array expr{*} v1-v@N@; do j=1 to dim(expr); expr{j}=j; end; actual=sum(of v:); run;
},sub {$_[0]*($_[0]+1)/2});
family('expression_log2_checksum',qr/\blog\s*\(/i,q{
data @P@a; do sample=1 to @N@; tpm=2**sample-1; logged=log2(tpm+1); output; end; run;
proc sql; create table @P@o as select sum(logged) as actual from @P@a; quit;
},sub {$_[0]*($_[0]+1)/2},undef,qr/Statistical|Statistics|Regression/i);
family('expression_median_by_gene',qr/^\s*proc\s+(?:summary|means)\b/i,q{
data @P@a; do gene=1 to 2; do sample=1 to 2*@N@+1; expression=sample*gene; output; end; end; run;
proc summary data=@P@a nway; class gene; var expression; output out=@P@b median=med; run;
proc sql; create table @P@o as select sum(med) as actual from @P@b; quit;
},sub {3*($_[0]+1)});
family('expression_missing_versus_zero',qr/^\s*array\b/i,q{
data @P@a; do sample=1 to @N@; expr1=.; expr2=0; output; end; run;
data @P@b; set @P@a; missing_count=cmiss(of expr:); run;
proc sql; create table @P@o as select sum(missing_count) as actual from @P@b; quit;
},sub {$_[0]});
family('gene_identifier_symbol_component',qr/\bscan\s*\(/i,q{
data @P@a; length gene $32; gene='ENSG01|MAP3K19'; expression=@N@; output; gene='ENSG02|R3HDM1'; expression=@NP1@; output; run;
data @P@b; set @P@a; symbol=scan(gene,2,'|'); if symbol in ('MAP3K19','R3HDM1'); run;
proc sql; create table @P@o as select sum(expression) as actual from @P@b; quit;
},sub {2*$_[0]+1});
family('phenotype_filter_before_aggregate',qr/^\s*where\b/i,q{
data @P@a; do sample=1 to @N@; sex='F'; expression=sample; output; sex='M'; expression=1000+sample; output; end; run;
proc means data=@P@a noprint; where sex='F'; var expression; output out=@P@o mean=actual; run;
},sub {($_[0]+1)/2},undef,qr/Clinical|Data Cleaning|Statistics/i);
family('wide_subset_keeps_only_required_columns',qr/^\s*keep\b/i,q{
data @P@a; length gene $12; gene='target'; unused=1000000; array exp{*} v1-v@N@; do j=1 to dim(exp); exp{j}=j; end; run;
data @P@b; set @P@a(keep=gene v: where=(gene='target')); run;
data @P@o; h=open('@P@b','i'); actual=attrn(h,'NVARS'); rc=close(h); run;
},sub {$_[0]+1});
family('cache_gate_avoids_unneeded_generation',qr/^\s*%if\b/i,q{
data @P@cache; value=@N@; run;
%macro @P@m;
%if %sysfunc(exist(work.@P@cache)) %then %do; data @P@o; set @P@cache; actual=value; run; %end;
%else %do; %put ERROR: Unexpected cache miss; %end;
%mend; %@P@m; %sysmacdelete @P@m;
},sub {$_[0]},undef,qr/Macro/i);
family('means_minimum_pair_idgroup',qr/^\s*proc\s+means\b/i,q{
data @P@a; do x=@N@+2 to 1 by -1; output; end; run;
proc means data=@P@a noprint; var x; output out=@P@b idgroup(min(x) out[2](x)=bottom); run;
data @P@o; set @P@b; actual=bottom_1+bottom_2; run;
},sub {3},undef,qr/Statistics|Statistical/i);
family('sort_ascii_case_order',qr/^\s*proc\s+sort\b/i,q{
data @P@a; length text $8; text='a'; value=@N@; output; text='A'; value=2*@N@; output; run;
proc sort data=@P@a out=@P@b sortseq=ascii; by text; run;
data @P@o; set @P@b(obs=1); actual=value; run;
},sub {2*$_[0]});
family('summary_classdata_empty_group',qr/^\s*proc\s+summary\b/i,q{
data @P@a; do j=1 to @N@; grp=1; x=j; output; end; run;
data @P@classes; grp=1; output; grp=2; output; run;
proc summary data=@P@a classdata=@P@classes nway completetypes; class grp; var x; output out=@P@b sum=total; run;
data @P@o; set @P@b; if grp=2; actual=_freq_; run;
},sub {0},undef,qr/TABULATE|Report|Programming/i);
family('transpose_multiple_id_delimiter',qr/^\s*proc\s+transpose\b/i,q{
data @P@a; label='A'; day=1; expression=@N@; output; label='B'; day=2; expression=2*@N@; output; run;
proc transpose data=@P@a out=@P@b delimiter=_; id label day; var expression; run;
data @P@o; set @P@b; actual=A_1+B_2; run;
},sub {3*$_[0]});
family('sql_all_subquery_boundary',qr/^\s*proc\s+sql\b/i,q{
data @P@a; do x=1 to @N@+1; output; end; run; data @P@b; do y=1 to @N@; output; end; run;
proc sql; create table @P@c as select x from @P@a where x>all(select y from @P@b);
create table @P@o as select sum(x) as actual from @P@c; quit;
},sub {$_[0]+1},undef,qr/SQL/i);
family('sql_any_subquery_boundary',qr/^\s*proc\s+sql\b/i,q{
data @P@a; do x=1 to @N@+1; output; end; run; data @P@b; do y=1 to @N@; output; end; run;
proc sql; create table @P@c as select x from @P@a where x>any(select y from @P@b);
create table @P@o as select count(*) as actual from @P@c; quit;
},sub {$_[0]},undef,qr/SQL/i);
family('contents_variable_position_checksum',qr/^\s*proc\s+contents\b/i,q{
data @P@a; array values{*} value1-value@N@; run;
proc contents data=@P@a out=@P@b noprint; run;
proc sql; create table @P@o as select sum(varnum) as actual from @P@b; quit;
},sub {$_[0]*($_[0]+1)/2});
family('special_missing_relational_order',qr/^\s*data\b/i,q{
data @P@a; do j=1 to @N@; x=.A; score=(x>. and x<0); output; end; run;
proc sql; create table @P@o as select sum(score) as actual from @P@a; quit;
},sub {$_[0]});
family('call_missing_clears_retained_values',qr/\bretain\b/i,q{
data @P@a; retain old1 old2 99; do j=1 to @N@; call missing(old1,old2); score=nmiss(old1,old2); output; old1=j; old2=j; end; run;
proc sql; create table @P@o as select sum(score) as actual from @P@a; quit;
},sub {2*$_[0]});
family('sum_function_versus_missing_addition',qr/\bsum\s*\(/i,q{
data @P@a; do j=1 to @N@; x=.; y=j; score=(sum(x,y)=j)+(missing(x+y)); output; end; run;
proc sql; create table @P@o as select sum(score) as actual from @P@a; quit;
},sub {2*$_[0]});
family('macro_prx_unquoted_greedy_tail',qr/%sysfunc\(/i,q{
%let @P@v=ABC@N@;
%let @P@found=%sysfunc(prxmatch(/ABC.*/,&@P@v));
data @P@o; actual=&@P@found; run; %symdel @P@v @P@found;
},sub {1},undef,qr/Macro/i);
family('macro_prxchange_greedy_replacement',qr/%sysfunc\(/i,q{
%let @P@v=ABC@N@;
%let @P@changed=%sysfunc(prxchange(s/ABC.*/Z/,-1,&@P@v));
data @P@o; actual=(symget('@P@changed')='Z'); run; %symdel @P@v @P@changed;
},sub {1},undef,qr/Macro/i);
family('macro_indexed_odd_step_sum',qr/%do\s+\w+\s*=/i,q{
%macro @P@m; %local i total; %let total=0;
%do i=1 %to %eval(2*@N@+1) %by 2; %let total=%eval(&total+&i); %end;
data @P@o; actual=&total; run; %mend; %@P@m; %sysmacdelete @P@m;
},sub {($_[0]+1)**2},undef,qr/Macro/i);
family('macro_formatted_integer_width',qr/%sysfunc\(/i,q{
%let @P@formatted=%sysfunc(putn(@N@,z4.));
data @P@o; text=symget('@P@formatted'); actual=lengthn(text)+input(text,best32.); run; %symdel @P@formatted;
},sub {$_[0]+4},undef,qr/Macro/i);
family('qsysfunc_masks_punctuation',qr/%sysfunc\(/i,q{
%let @P@text=%qsysfunc(tranwrd(%str(A,B),%str(,),%str(;)));
data @P@o; text=symget('@P@text'); actual=(text='A;B')+@N@; run; %symdel @P@text;
},sub {$_[0]+1},undef,qr/Macro/i);
family('failure_sql_in_type_mismatch',qr/^\s*proc\s+sql\b/i,q{
data @P@a; x=@N@; run; data @P@b; length y $8; y='@N@'; run;
proc sql; create table @P@o as select * from @P@a where x in (select y from @P@b); quit;
},undef,'(?:different data types|not the same data type)',qr/SQL/i);
family('failure_classdata_type_mismatch',qr/^\s*proc\s+summary\b/i,q{
data @P@a; grp=@N@; x=1; run; data @P@classes; length grp $8; grp='@N@'; run;
proc summary data=@P@a classdata=@P@classes nway; class grp; var x; output out=@P@b sum=total; run;
},undef,'(?:incompatible|type|numeric|character)',qr/Programming|Report/i);
family('failure_unassigned_output_libref',qr/^\s*libname\b/i,q{
data Z@P@.out; x=@N@; run;
},undef,'Libref.*not assigned');
family('failure_invalid_sysevalf_conversion',qr/%sysevalf\(/i,q{
%let @P@v=%sysevalf(@N@+0.5,not_a_conversion); %symdel @P@v / nowarn;
},undef,'(?:conversion|argument)',qr/Macro/i);
family('failure_array_subscript_upper_bound',qr/^\s*array\b/i,q{
data @P@a; array values{2} x y; i=@N@+2; values{i}=1; run;
},undef,'Array subscript out of range');
Library_Evaluation_Corpus::write_corpus(library=>$books,destination=>$destination,round=>10,letter=>'K',start=>4051,
    families=>\@families,source_directories=>['.'],source_extension=>'txt',source_kind=>'book_sample',
    description=>'Book-derived probability identities, bounded gene-matrix operations, dataset metadata, SQL and macro quoting; 450 positive and 50 intended program errors');
