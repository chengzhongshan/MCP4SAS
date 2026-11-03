#!/usr/bin/env perl
use strict; use warnings;
use FindBin qw($Bin); use lib "$Bin/lib"; use Library_Evaluation_Corpus;
my ($books,$destination)=@ARGV;
die "Usage: $0 BOOK_SAMPLE_DIRECTORY [OUTPUT_DIRECTORY]\n" unless defined $books && -d $books;
$destination //= "$Bin/../tests/library500_round8";
my @families;
my $base=qr/(?:Programming|Little SAS Book|Combining|Data Cleaning)/i;
my $stat=qr/(?:Multivariate|Statistical|Statistics|Linear Models|Regression)/i;
my $sql=qr/(?:SQL)/i;
sub family {push @families,{name=>$_[0],pattern=>$_[1],body=>$_[2],oracle=>$_[3],diagnostic=>$_[4],book_pattern=>$_[5]//$base,tolerance=>$_[6]//'1e-9'};}
family('princomp_covariance_trace',qr/^\s*proc\s+princomp\b/i,q{
data @P@a; do j=1 to @N@; x=-j; y=2*x; output; x=j; y=2*x; output; end; run;
proc princomp data=@P@a cov outstat=@P@b noprint; var x y; run;
data @P@o; set @P@b; if _type_='EIGENVAL'; actual=sum(x,y); run;
},sub {my $n=shift; 10*$n*($n+1)*(2*$n+1)/6/(2*$n-1)},undef,$stat,'1e-6');
family('princomp_correlation_eigenvalue',qr/^\s*proc\s+princomp\b/i,q{
data @P@a; do j=1 to @N@; x=-j; y=2*x; output; x=j; y=2*x; output; end; run;
proc princomp data=@P@a outstat=@P@b noprint; var x y; run;
data @P@o; set @P@b; if _type_='EIGENVAL'; actual=x; run;
},sub {2},undef,$stat,'1e-6');
family('princomp_eigenvector_norm',qr/^\s*proc\s+princomp\b/i,q{
data @P@a; do j=1 to @N@; x=-j; y=2*x; output; x=j; y=2*x; output; end; run;
proc princomp data=@P@a cov outstat=@P@b noprint; var x y; run;
data @P@o; set @P@b; if _type_='SCORE' and upcase(_name_)='PRIN1'; actual=x*x+y*y; run;
},sub {1},undef,$stat,'1e-6');
family('princomp_score_energy',qr/^\s*proc\s+princomp\b/i,q{
data @P@a; do j=1 to @N@; x=-j; y=2*x; output; x=j; y=2*x; output; end; run;
proc princomp data=@P@a cov out=@P@b noprint; var x y; run;
proc sql; create table @P@o as select sum(prin1*prin1) as actual from @P@b; quit;
},sub {my $n=shift; 10*$n*($n+1)*(2*$n+1)/6},undef,$stat,'1e-6');
family('tabulate_sum_output',qr/^\s*proc\s+tabulate\b/i,q{
data @P@a; do x=1 to @N@; output; end; run;
proc tabulate data=@P@a out=@P@b; var x; table x*sum; run;
data @P@o; set @P@b; actual=x_sum; run;
},sub {$_[0]*($_[0]+1)/2},undef,qr/TABULATE|Report/i);
family('standard_replace_mean',qr/^\s*proc\s+standard\b/i,q{
data @P@a; do x=1 to @N@; id=x; output; end; x=.; id=0; output; run;
proc standard data=@P@a out=@P@b mean=@N@ std=1 replace; var x; run;
data @P@o; set @P@b; if id=0; actual=x; run;
},sub {$_[0]},undef,$stat);
family('standard_preserve_missing',qr/^\s*proc\s+standard\b/i,q{
data @P@a; do x=1 to @N@; output; end; x=.; output; run;
proc standard data=@P@a out=@P@b mean=10 std=2; var x; run;
proc sql; create table @P@o as select sum(missing(x)) as actual from @P@b; quit;
},sub {1},undef,$stat);
family('standard_selected_columns',qr/^\s*proc\s+standard\b/i,q{
data @P@a; do x=1 to @N@; y=x*x; output; end; run;
proc standard data=@P@a out=@P@b mean=0 std=1; var x; run;
proc sql; create table @P@o as select sum(y) as actual from @P@b; quit;
},sub {$_[0]*($_[0]+1)*(2*$_[0]+1)/6},undef,$stat);
family('anova_error_ss',qr/^\s*proc\s+anova\b/i,q{
data @P@a; do grp=1 to 2; do j=1 to @N@; y=10*grp+j; output; end; end; run;
ods output OverallANOVA=@P@b;
proc anova data=@P@a; class grp; model y=grp; run; quit;
ods output close;
data @P@o; set @P@b; if upcase(source)='ERROR'; actual=ss; run;
},sub {$_[0]*($_[0]**2-1)/6},undef,$stat,'1e-6');
family('anova_model_ss',qr/^\s*proc\s+anova\b/i,q{
data @P@a; do grp=1 to 2; do j=1 to @N@; y=10*grp+j; output; end; end; run;
ods output OverallANOVA=@P@b;
proc anova data=@P@a; class grp; model y=grp; run; quit;
ods output close;
data @P@o; set @P@b; if upcase(source)='MODEL'; actual=ss; run;
},sub {50*$_[0]},undef,$stat,'1e-6');
family('reg_quadratic_coefficient',qr/^\s*proc\s+reg\b/i,q{
data @P@a; do x=1 to @N@+3; x2=x*x; y=5+2*x+3*x2; output; end; run;
proc reg data=@P@a outest=@P@b noprint; model y=x x2; run; quit;
data @P@o; set @P@b; actual=x2; run;
},sub {3},undef,$stat,'1e-6');
family('reg_noint_slope',qr/^\s*proc\s+reg\b/i,q{
data @P@a; do x=1 to @N@; y=3*x; output; end; run;
proc reg data=@P@a outest=@P@b noprint; model y=x / noint; run; quit;
data @P@o; set @P@b; actual=x; run;
},sub {3},undef,$stat,'1e-6');
family('reg_perfect_fit_rsquare',qr/^\s*proc\s+reg\b/i,q{
data @P@a; do x=1 to @N@+2; y=7+4*x; output; end; run;
proc reg data=@P@a outest=@P@b rsquare noprint; model y=x; run; quit;
data @P@o; set @P@b; actual=_rsq_; run;
},sub {1},undef,$stat,'1e-6');
family('glm_interaction_parameter',qr/^\s*proc\s+glm\b/i,q{
data @P@a; do j=1 to @N@; do sign=-1 to 1 by 2; x=sign*j; do z=-1 to 1 by 2; y=3+2*x+4*z+5*x*z; output; end; end; end; run;
ods output ParameterEstimates=@P@b;
proc glm data=@P@a; model y=x z x*z / solution; run; quit;
ods output close;
data @P@o; set @P@b; if upcase(parameter)='X*Z'; actual=estimate; run;
},sub {5},undef,$stat,'1e-6');
family('freq_chisquare_independence',qr/^\s*proc\s+freq\b/i,q{
data @P@a; do row=1 to 2; do col=1 to 2; count=@N@; output; end; end; run;
ods output ChiSq=@P@b;
proc freq data=@P@a; tables row*col / chisq; weight count; run;
ods output close;
data @P@o; set @P@b; if statistic='Chi-Square'; actual=value; run;
},sub {0},undef,qr/Categorical|Statistics|Statistical/i,'1e-6');
family('array_nonunit_two_dimensions',qr/^\s*array\b/i,q{
data @P@o; array cells{-1:1,2:3} _temporary_; actual=0;
do i=-1 to 1; do j=2 to 3; cells{i,j}=@N@+10*i+j; actual=actual+cells{i,j}; end; end; run;
},sub {6*$_[0]+15});
family('temporary_array_shift_register',qr/^\s*array\b/i,q{
data @P@o; array queue{3} _temporary_ (0 0 0);
do j=1 to @N@+3; queue{3}=queue{2}; queue{2}=queue{1}; queue{1}=j; end;
actual=sum(of queue{*}); run;
},sub {3*$_[0]+6});
family('array_vname_metadata',qr/^\s*array\b/i,q{
data @P@o; value1=@N@; value2=2*@N@; value3=3*@N@; array vals{3} value1-value3;
actual=0; do j=1 to 3; actual=actual+input(substr(vname(vals{j}),6),8.)*vals{j}; end; run;
},sub {14*$_[0]});
family('whichn_array_position',qr/^\s*array\b/i,q{
data @P@o; array values{4} a b c d; a=-1; b=-2; c=@N@; d=-4;
actual=whichn(@N@,of values{*}); run;
},sub {3});
family('do_while_empty_iteration',qr/^\s*do\b/i,q{
data @P@o; actual=@N@; do while(actual<0); actual=actual+100; end; run;
},sub {$_[0]});
family('do_until_bottom_test',qr/^\s*do\b/i,q{
data @P@o; actual=@N@; do until(actual>=@N@); actual=actual+1; end; run;
},sub {$_[0]+1});
family('nested_dependent_do_bounds',qr/^\s*do\b/i,q{
data @P@o; actual=0; do i=1 to @N@; do j=1 to i; actual=actual+i*j; end; end; run;
},sub {my $n=shift; my $sum=0; for my $i (1..$n) {$sum+=$i*$i*($i+1)/2} $sum});
family('name_literal_datastep',qr/^\s*data\b/i,q{
%let @P@saved=%sysfunc(getoption(validvarname,keyword));
options validvarname=any;
data @P@o; 'patient age'n=@N@; actual='patient age'n+1; run;
options &@P@saved;
%symdel @P@saved;
},sub {$_[0]+1});
family('name_literal_sql',qr/^\s*proc\s+sql\b/i,q{
%let @P@saved=%sysfunc(getoption(validvarname,keyword));
options validvarname=any;
data @P@a; do 'visit day'n=1 to @N@; output; end; run;
proc sql; create table @P@o as select sum('visit day'n) as actual from @P@a; quit;
options &@P@saved;
%symdel @P@saved;
},sub {$_[0]*($_[0]+1)/2},undef,$sql);
family('by_notsorted_run_count',qr/\bby\b.*\bnotsorted\b/i,q{
data @P@a; do run=1 to 3; grp=mod(run,2); do j=1 to @N@; output; end; end; run;
data @P@b; set @P@a; by grp notsorted; if first.grp; run;
proc sql; create table @P@o as select count(*) as actual from @P@b; quit;
},sub {3});
family('by_descending_boundary_checksum',qr/^\s*by\b/i,q{
data @P@a; do grp=@N@ to 1 by -1; do j=1 to 2; output; end; end; run;
data @P@b; set @P@a; by descending grp; score=first.grp+10*last.grp; run;
proc sql; create table @P@o as select sum(score) as actual from @P@b; quit;
},sub {11*$_[0]});
family('set_indsname_origin',qr/^\s*set\b/i,q{
data @P@a; x=@N@; run; data @P@b; x=@NP1@; run;
data @P@c; set @P@a @P@b indsname=origin; flag=(upcase(origin)=upcase("WORK.@P@b")); run;
proc sql; create table @P@o as select sum(flag*x) as actual from @P@c; quit;
},sub {$_[0]+1});
family('output_keep_and_rename_order',qr/^\s*data\b/i,q{
data @P@a(keep=original rename=(original=renamed)); original=@N@; hidden=100; run;
proc sql; create table @P@o as select renamed as actual from @P@a; quit;
},sub {$_[0]});
family('input_rename_before_where',qr/^\s*set\b/i,q{
data @P@a; do original=1 to @N@+2; output; end; run;
data @P@b; set @P@a(rename=(original=renamed) where=(renamed>@N@)); run;
proc sql; create table @P@o as select sum(renamed) as actual from @P@b; quit;
},sub {2*$_[0]+3});
family('datasets_label_semicolon',qr/^\s*proc\s+datasets\b/i,q{
data @P@a; x=@N@; run;
proc datasets library=work nolist; modify @P@a(label='phase; two'); quit;
data @P@o; h=open('@P@a','i'); actual=(attrc(h,'LABEL')='phase; two'); rc=close(h); run;
},sub {1});
family('sql_into_delimited_values',qr/\binto\s*:/i,q{
data @P@a; do x=1 to @N@; output; end; run;
proc sql noprint; select x into :@P@list separated by '|' from @P@a order by x; quit;
data @P@o; actual=countw(symget('@P@list'),'|'); run;
%symdel @P@list;
},sub {$_[0]},undef,qr/Macro|SQL|Data Cleaning/i);
family('sql_into_numbered_variables',qr/\binto\s*:/i,q{
data @P@a; do x=1 to @N@; output; end; run;
proc sql noprint; select x into :@P@item1-:@P@item@N@ from @P@a order by x; quit;
data @P@o; actual=input(symget('@P@item@N@'),best32.); run;
%macro @P@clear; %do j=1 %to @N@; %symdel @P@item&j; %end; %mend; %@P@clear;
%sysmacdelete @P@clear;
},sub {$_[0]},undef,qr/Macro|SQL/i);
family('sql_three_way_cross_join',qr/^\s*proc\s+sql\b/i,q{
data @P@a; do x=1 to @N@; output; end; run;
data @P@b; do y=1 to 2; output; end; run; data @P@c; do z=1 to 3; output; end; run;
proc sql; create table @P@o as select count(*) as actual from @P@a,@P@b,@P@c; quit;
},sub {6*$_[0]},undef,$sql);
family('sql_union_corresponding_columns',qr/\bunion\b/i,q{
data @P@a; x=@N@; y=100; run;
data @P@b; y=200; x=@NP1@; run;
proc sql; create table @P@c as select x,y from @P@a union corr select y,x from @P@b;
create table @P@o as select sum(x) as actual from @P@c; quit;
},sub {2*$_[0]+1},undef,$sql);
family('sql_intersect_all_multiplicity',qr/^\s*intersect\b/i,q{
data @P@a; do j=1 to @N@+2; x=1; output; end; run;
data @P@b; do j=1 to @N@; x=1; output; end; run;
proc sql; create table @P@c as select x from @P@a intersect all select x from @P@b;
create table @P@o as select count(*) as actual from @P@c; quit;
},sub {$_[0]},undef,$sql);
family('sql_except_all_multiplicity',qr/^\s*except\b/i,q{
data @P@a; do j=1 to @N@+2; x=1; output; end; run;
data @P@b; do j=1 to @N@; x=1; output; end; run;
proc sql; create table @P@c as select x from @P@a except all select x from @P@b;
create table @P@o as select count(*) as actual from @P@c; quit;
},sub {2},undef,$sql);
family('sql_scalar_subquery_sum',qr/^\s*proc\s+sql\b/i,q{
data @P@a; x=@N@; run; data @P@b; do y=1 to @N@; output; end; run;
proc sql; create table @P@o as select x+(select sum(y) from @P@b) as actual from @P@a; quit;
},sub {$_[0]+$_[0]*($_[0]+1)/2},undef,$sql);
family('sql_having_unselected_aggregate',qr/\bhaving\b/i,q{
data @P@a; do grp=1 to 2; do j=1 to @N@; x=grp; output; end; end; run;
proc sql; create table @P@b as select grp from @P@a group by grp having sum(x)>@N@;
create table @P@o as select sum(grp) as actual from @P@b; quit;
},sub {2},undef,$sql);
family('summary_preloadfmt_empty_class',qr/^\s*class\b.*\bpreloadfmt\b/i,q{
proc format; value @P@fmt 1='present' 2='absent'; run;
data @P@a; do j=1 to @N@; grp=1; x=j; output; end; format grp @P@fmt.; run;
proc summary data=@P@a nway completetypes; class grp / preloadfmt; var x; output out=@P@b sum=total; run;
data @P@o; set @P@b; format grp; if grp=2; actual=_freq_; run;
proc catalog catalog=work.formats; delete @P@fmt.format; quit;
},sub {0},undef,qr/Report|TABULATE/i);
family('summary_multilabel_membership',qr/^\s*value\b.*\bmultilabel\b/i,q{
proc format; value @P@fmt(multilabel) 1-2='all' 1='one' 2='two'; run;
data @P@a; do j=1 to @N@; do grp=1 to 2; output; end; end; format grp @P@fmt.; run;
proc summary data=@P@a nway; class grp / mlf; output out=@P@b; run;
proc sql; create table @P@o as select sum(_freq_) as actual from @P@b; quit;
proc catalog catalog=work.formats; delete @P@fmt.format; quit;
},sub {4*$_[0]},undef,qr/FORMAT/i);
family('freq_oneway_chisquare_uniform',qr/^\s*proc\s+freq\b/i,q{
data @P@a; do level=1 to 3; count=@N@; output; end; run;
ods output OneWayChiSq=@P@b;
proc freq data=@P@a; tables level / chisq; weight count; run;
ods output close;
data @P@o; set @P@b; if name1='_PCHI_'; actual=nvalue1; run;
},sub {0},undef,qr/Categorical|Statistics|Statistical/i,'1e-6');
family('rank_normal_blom_symmetry',qr/^\s*proc\s+rank\b/i,q{
data @P@a; do x=1 to @N@+2; output; end; run;
proc rank data=@P@a out=@P@b normal=blom; var x; ranks score; run;
proc sql; create table @P@o as select sum(score) as actual from @P@b; quit;
},sub {0},undef,$stat,'1e-6');
family('rank_normal_tukey_symmetry',qr/^\s*proc\s+rank\b/i,q{
data @P@a; do x=1 to @N@+2; output; end; run;
proc rank data=@P@a out=@P@b normal=tukey; var x; ranks score; run;
proc sql; create table @P@o as select sum(score) as actual from @P@b; quit;
},sub {0},undef,$stat,'1e-6');
family('rank_normal_vw_symmetry',qr/^\s*proc\s+rank\b/i,q{
data @P@a; do x=1 to @N@+2; output; end; run;
proc rank data=@P@a out=@P@b normal=vw; var x; ranks score; run;
proc sql; create table @P@o as select sum(score) as actual from @P@b; quit;
},sub {0},undef,$stat,'1e-6');
family('compare_difference_output',qr/^\s*proc\s+compare\b/i,q{
data @P@a; do x=1 to @N@; output; end; run;
data @P@b; set @P@a; x=x+2; run;
proc compare base=@P@a compare=@P@b out=@P@c outdif noprint; var x; run;
proc sql; create table @P@o as select sum(abs(x)) as actual from @P@c where _type_='DIF'; quit;
},sub {2*$_[0]},undef,qr/Mixed Models|Clinical|Programming/i);
family('failure_scalar_multiple_rows',qr/^\s*proc\s+sql\b/i,q{
data @P@a; x=@N@; run; data @P@b; do y=1 to @N@; output; end; run;
proc sql; create table @P@o as select x+(select y from @P@b) as actual from @P@a; quit;
},undef,'(?:more than one row|multiple rows)',$sql);
family('failure_sort_missing_key',qr/^\s*proc\s+sort\b/i,q{
data @P@a; do x=1 to @N@; output; end; run;
proc sort data=@P@a out=@P@b; by @P@absent; run;
},undef,'(?:not found|not on file|does not exist)');
family('failure_summary_character_analysis',qr/^\s*proc\s+(?:summary|means)\b/i,q{
data @P@a; length text $12; text='@N@'; run;
proc summary data=@P@a; var text; output out=@P@b sum=total; run;
},undef,'(?:type|numeric)');
family('failure_princomp_character_analysis',qr/^\s*proc\s+princomp\b/i,q{
data @P@a; length text $12; text='@N@'; run;
proc princomp data=@P@a noprint; var text; run;
},undef,'(?:type|numeric)',$stat);
family('failure_format_reversed_range',qr/^\s*proc\s+format\b/i,q{
proc format; value @P@fmt @NP1@-@N@='reversed'; run;
proc catalog catalog=work.formats; delete @P@fmt.format; quit;
},undef,'(?:range|smaller|greater|less than)',qr/FORMAT|Data Cleaning/i);
Library_Evaluation_Corpus::write_corpus(library=>$books,destination=>$destination,round=>8,letter=>'J',start=>3501,
    families=>\@families,source_directories=>['.'],source_extension=>'txt',source_kind=>'book_sample',
    description=>'Second book-sample round: PCA/ANOVA, reporting, normal scores, PDV/array boundaries, SQL multisets and formatted groups; 450 positive and 50 intentional-error scenarios');
