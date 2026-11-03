#!/usr/bin/env perl
use strict; use warnings;
use FindBin qw($Bin); use lib "$Bin/lib"; use Library_Evaluation_Corpus;
my ($books,$destination)=@ARGV;
die "Usage: $0 BOOK_SAMPLE_DIRECTORY [OUTPUT_DIRECTORY]\n" unless defined $books && -d $books;
$destination //= "$Bin/../tests/library500_round7";
my @families;
my $base=qr/(?:Programming|Little SAS Book|Data Cleaning|Combining and Modifying)/i;
my $sql=qr/(?:SQL|Data Preparation)/i;
my $stat=qr/(?:Statistical|Statistics|Linear Models|Mixed Models|Regression|Clinical|Categorical)/i;
sub family {push @families,{name=>$_[0],pattern=>$_[1],body=>$_[2],oracle=>$_[3],diagnostic=>$_[4],book_pattern=>$_[5]//$base,tolerance=>$_[6]//'1e-9'};}
family('select_when_otherwise',qr/^\s*(?:select|when)\b/i,q{
data @P@a; do code=0 to @N@; select(code); when(0) score=100; otherwise score=code; end; output; end; run;
proc sql; create table @P@o as select sum(score) as actual from @P@a; quit;
},sub {100+$_[0]*($_[0]+1)/2});
family('select_without_expression',qr/^\s*select\b/i,q{
data @P@a; do x=-@N@ to @N@; select; when(x<0) score=-x; when(x=0) score=10; otherwise score=2*x; end; output; end; run;
proc sql; create table @P@o as select sum(score) as actual from @P@a; quit;
},sub {10+3*$_[0]*($_[0]+1)/2});
family('link_return_subroutine',qr/^\s*link\b/i,q{
data @P@o; total=0; do x=1 to @N@; link square; end; actual=total; output; stop;
square: total=total+x*x; return; run;
},sub {$_[0]*($_[0]+1)*(2*$_[0]+1)/6});
family('goto_local_label',qr/^\s*(?:go\s*to|goto|link)\b/i,q{
data @P@a; do x=1 to @N@; if mod(x,2)=0 then goto even; score=x; goto emit;
even: score=10*x;
emit: output; end; stop; run;
proc sql; create table @P@o as select sum(score) as actual from @P@a; quit;
},sub {my $n=shift; my $s=0; $s+=($_%2?$_:10*$_) for 1..$n; $s});
family('do_leave_threshold',qr/\bleave\s*;/i,q{
data @P@o; actual=0; do x=1 to 100; if x>@N@ then leave; actual=actual+x; end; run;
},sub {$_[0]*($_[0]+1)/2});
family('do_continue_filter',qr/\bcontinue\s*;/i,q{
data @P@o; actual=0; do x=1 to 2*@N@; if mod(x,2)=1 then continue; actual=actual+x; end; run;
},sub {$_[0]*($_[0]+1)});
family('do_list_and_range',qr/^\s*do\b/i,q{
data @P@a; do x=1 to @N@,2*@N@; output; end; run;
proc sql; create table @P@o as select sum(x) as actual from @P@a; quit;
},sub {$_[0]*($_[0]+1)/2+2*$_[0]});
family('multi_output_partition',qr/^\s*output\b/i,q{
data @P@a @P@b; do x=-@N@ to @N@; if x<0 then output @P@a; else if x>0 then output @P@b; end; run;
proc sql; create table @P@c as select sum(x) as negative from @P@a;
create table @P@d as select sum(x) as positive from @P@b;
create table @P@o as select positive-negative as actual from @P@c,@P@d; quit;
},sub {$_[0]*($_[0]+1)});
family('delete_and_explicit_outputs',qr/^\s*(?:delete|output)\b/i,q{
data @P@a; do x=1 to 2*@N@; output; end; run;
data @P@b; set @P@a; if mod(x,2)=1 then delete; output; output; run;
proc sql; create table @P@o as select sum(x) as actual from @P@b; quit;
},sub {2*$_[0]*($_[0]+1)});
family('multiple_set_shorter_stream',qr/^\s*set\b/i,q{
data @P@a; do x=1 to @N@+2; output; end; run;
data @P@b; do y=1 to @N@; output; end; run;
data @P@c; set @P@a; set @P@b; value=x+y; run;
proc sql; create table @P@o as select sum(value) as actual from @P@c; quit;
},sub {$_[0]*($_[0]+1)});
family('merge_one_to_many_retention',qr/^\s*merge\b/i,q{
data @P@a; k=1; value=@N@; run;
data @P@b; k=1; do j=1 to @N@; output; end; run;
data @P@c; merge @P@a @P@b; by k; run;
proc sql; create table @P@o as select sum(value) as actual from @P@c; quit;
},sub {$_[0]**2},undef,qr/Combining and Modifying/i);
family('merge_many_to_many_retention',qr/^\s*merge\b/i,q{
data @P@a; k=1; value=1; output; value=2; output; run;
data @P@b; k=1; do j=1 to @N@; output; end; run;
data @P@c; merge @P@a @P@b; by k; run;
proc sql; create table @P@o as select sum(value) as actual from @P@c; quit;
},sub {2*$_[0]-1},undef,qr/Combining and Modifying/i);
family('update_multiple_transactions',qr/^\s*update\b/i,q{
data @P@a; do k=1 to @N@; x=10*k; y=20*k; output; end; run;
data @P@b; do k=1 to @N@; x=.; y=@N@; output; x=@NP1@; y=.; output; end; run;
data @P@c; update @P@a @P@b; by k; run;
proc sql; create table @P@o as select sum(x+y) as actual from @P@c; quit;
},sub {$_[0]*(2*$_[0]+1)},undef,qr/Combining and Modifying/i);
family('set_in_origin_flags',qr/\bin\s*=/i,q{
data @P@a; do x=1 to @N@; output; end; run;
data @P@b; do x=1 to @NP1@; output; end; run;
data @P@c; set @P@a(in=ina) @P@b(in=inb); value=ina+10*inb; run;
proc sql; create table @P@o as select sum(value) as actual from @P@c; quit;
},sub {11*$_[0]+10},undef,qr/Combining and Modifying/i);
family('summary_ways_grand_and_class',qr/^\s*proc\s+(?:summary|means)\b/i,q{
data @P@a; do grp=1 to @N@; value=1; output; output; end; run;
proc summary data=@P@a; class grp; ways 0 1; var value; output out=@P@b sum=total; run;
proc sql; create table @P@o as select sum(_freq_)+count(*) as actual from @P@b; quit;
},sub {5*$_[0]+1});
family('means_top_two_idgroup',qr/^\s*proc\s+means\b/i,q{
data @P@a; do x=1 to @N@; output; end; run;
proc means data=@P@a noprint; var x; output out=@P@b idgroup(max(x) out[2](x)=top); run;
data @P@o; set @P@b; actual=top_1+top_2; run;
},sub {2*$_[0]-1});
family('means_autoname_columns',qr/^\s*proc\s+means\b/i,q{
data @P@a; do x=1 to @N@; y=2*x; output; end; run;
proc means data=@P@a noprint; var x y; output out=@P@b mean= / autoname; run;
data @P@o; set @P@b; actual=x_mean+y_mean; run;
},sub {3*($_[0]+1)/2});
family('freq_order_frequency',qr/^\s*proc\s+freq\b/i,q{
data @P@a; do k=1 to @N@; do j=1 to @N@-k+1; output; end; end; run;
proc freq data=@P@a order=freq noprint; tables k / out=@P@b; run;
data @P@o; set @P@b; if _n_=1; actual=k+count; run;
},sub {$_[0]+1});
family('freq_missing_denominator',qr/^\s*proc\s+freq\b/i,q{
data @P@a; do k=1 to @N@; output; end; k=.; output; output; run;
proc freq data=@P@a noprint; tables k / missing out=@P@b; run;
data @P@o; set @P@b; if missing(k); actual=percent; run;
},sub {200/($_[0]+2)});
family('logistic_balanced_intercept',qr/^\s*proc\s+logistic\b/i,q{
data @P@a; do y=0 to 1; do j=1 to @N@; output; end; end; run;
proc logistic data=@P@a noprint; model y(event='1')=; output out=@P@b p=prob; run;
proc sql; create table @P@o as select mean(prob) as actual from @P@b; quit;
},sub {0.5},undef,qr/Logistic Regression|Categorical Data/i,'1e-6');
family('logistic_unbalanced_intercept',qr/^\s*proc\s+logistic\b/i,q{
data @P@a; do j=1 to @N@; y=1; output; y=0; output; output; end; run;
proc logistic data=@P@a noprint; model y(event='1')=; output out=@P@b p=prob; run;
proc sql; create table @P@o as select mean(prob) as actual from @P@b; quit;
},sub {1/3},undef,qr/Logistic Regression|Categorical Data/i,'1e-6');
family('logistic_binary_predictor_cells',qr/^\s*proc\s+logistic\b/i,q{
data @P@a; do j=1 to @N@; grp=0; y=1; output; y=0; output; output; grp=1; y=0; output; y=1; output; output; end; run;
proc logistic data=@P@a noprint; model y(event='1')=grp / gconv=1e-12; output out=@P@b p=prob; run;
proc sql; create table @P@o as select mean(prob) as actual from @P@b where grp=1; quit;
},sub {2/3},undef,qr/Logistic Regression|Categorical Data/i,'1e-6');
family('logistic_freq_aggregates',qr/^\s*proc\s+logistic\b/i,q{
data @P@a; y=0; weight=@N@; output; y=1; weight=2*@N@; output; run;
proc logistic data=@P@a noprint; freq weight; model y(event='1')=; output out=@P@b p=prob; run;
proc sql; create table @P@o as select mean(prob) as actual from @P@b; quit;
},sub {2/3},undef,qr/Logistic Regression|Categorical Data/i,'1e-6');
family('genmod_poisson_intercept',qr/^\s*proc\s+genmod\b/i,q{
data @P@a; do j=1 to @N@; count=@N@; output; end; run;
proc genmod data=@P@a; model count= / dist=poisson link=log; output out=@P@b pred=prediction; run;
proc sql; create table @P@o as select mean(prediction) as actual from @P@b; quit;
},sub {$_[0]},undef,$stat,'1e-6');
family('genmod_poisson_groups',qr/^\s*proc\s+genmod\b/i,q{
data @P@a; do grp=0 to 1; do j=1 to 3; count=@N@*(1+grp); output; end; end; run;
proc genmod data=@P@a; model count=grp / dist=poisson link=log; output out=@P@b pred=prediction; run;
proc sql; create table @P@o as select mean(prediction) as actual from @P@b where grp=1; quit;
},sub {2*$_[0]},undef,$stat,'1e-6');
family('genmod_binomial_trials',qr/^\s*proc\s+genmod\b/i,q{
data @P@a; do j=1 to 3; events=@N@; trials=3*@N@; output; end; run;
proc genmod data=@P@a; model events/trials= / dist=binomial link=logit; output out=@P@b pred=prediction; run;
proc sql; create table @P@o as select mean(prediction) as actual from @P@b; quit;
},sub {1/3},undef,$stat,'1e-6');
family('genmod_poisson_exposure_offset',qr/^\s*proc\s+genmod\b/i,q{
data @P@a; do exposure=1 to 3; count=@N@*exposure; offset=log(exposure); output; end; run;
proc genmod data=@P@a; model count= / dist=poisson link=log offset=offset; output out=@P@b pred=prediction; run;
proc sql; create table @P@o as select mean(prediction/exposure) as actual from @P@b; quit;
},sub {$_[0]},undef,$stat,'1e-6');
family('mixed_intercept_estimate',qr/^\s*proc\s+mixed\b/i,q{
data @P@a; do y=1 to @N@+2; output; end; run;
ods output SolutionF=@P@b;
proc mixed data=@P@a method=reml; model y= / solution; run;
ods output close;
data @P@o; set @P@b; actual=estimate; run;
},sub {($_[0]+3)/2},undef,qr/Mixed Models|Linear Models/i,'1e-6');
family('mixed_symmetric_slope',qr/^\s*proc\s+mixed\b/i,q{
data @P@a; do j=1 to @N@; err=(-1)**j; x=-j; y=5+3*x+err; output; x=j; y=5+3*x+err; output; end; run;
ods output SolutionF=@P@b;
proc mixed data=@P@a method=reml; model y=x / solution; run;
ods output close;
data @P@o; set @P@b; if upcase(effect)='X'; actual=estimate; run;
},sub {3},undef,qr/Mixed Models|Linear Models/i,'1e-6');
family('ttest_one_sample_statistics',qr/^\s*proc\s+ttest\b/i,q{
data @P@a; do x=1 to @N@+2; output; end; run;
ods output Statistics=@P@b;
proc ttest data=@P@a h0=0; var x; run;
ods output close;
data @P@o; set @P@b; actual=mean; run;
},sub {($_[0]+3)/2},undef,$stat);
family('ttest_paired_statistics',qr/^\s*proc\s+ttest\b/i,q{
data @P@a; do before=1 to @N@+2; after=0; output; end; run;
ods output Statistics=@P@b;
proc ttest data=@P@a; paired before*after; run;
ods output close;
data @P@o; set @P@b; actual=mean; run;
},sub {($_[0]+3)/2},undef,$stat);
family('ttest_two_group_difference',qr/^\s*proc\s+ttest\b/i,q{
data @P@a; do grp=1 to 2; do j=1 to @N@+2; x=j+10*(grp-1); output; end; end; run;
ods output Statistics=@P@b;
proc ttest data=@P@a; class grp; var x; run;
ods output close;
data @P@o; set @P@b; if index(upcase(class),'DIFF')=1 and upcase(method)='POOLED'; actual=mean; run;
},sub {-10},undef,$stat);
family('corr_kendall_monotonic',qr/^\s*proc\s+corr\b/i,q{
data @P@a; do x=1 to @N@+2; y=x*x*x; output; end; run;
proc corr data=@P@a outk=@P@b kendall noprint; var x y; run;
data @P@o; set @P@b; if _type_='CORR' and upcase(_name_)='X'; actual=y; run;
},sub {1},undef,$stat);
family('corr_partial_control',qr/^\s*proc\s+corr\b/i,q{
data @P@a; do j=1 to @N@; z=mod(j,2); x=-j; y=2*x+3*z; output; x=j; y=2*x+3*z; output; end; run;
proc corr data=@P@a outp=@P@b noprint; var x y; partial z; run;
data @P@o; set @P@b; if _type_='CORR' and upcase(_name_)='X'; actual=y; run;
},sub {1},undef,$stat);
family('corr_population_covariance',qr/^\s*proc\s+corr\b/i,q{
data @P@a; do x=1 to @N@; y=3*x; output; end; run;
proc corr data=@P@a outp=@P@b cov vardef=n noprint; var x y; run;
data @P@o; set @P@b; if _type_='COV' and upcase(_name_)='X'; actual=y; run;
},sub {($_[0]**2-1)/4},undef,$stat);
family('rank_fraction_denominator',qr/^\s*proc\s+rank\b/i,q{
data @P@a; do x=1 to @N@; output; end; run;
proc rank data=@P@a out=@P@b fraction; var x; ranks fraction; run;
proc sql; create table @P@o as select mean(fraction) as actual from @P@b; quit;
},sub {($_[0]+1)/(2*$_[0])});
family('rank_nplus1_denominator',qr/^\s*proc\s+rank\b/i,q{
data @P@a; do x=1 to @N@; output; end; run;
proc rank data=@P@a out=@P@b nplus1; var x; ranks fraction; run;
proc sql; create table @P@o as select mean(fraction) as actual from @P@b; quit;
},sub {0.5});
family('rank_percent_sum',qr/^\s*proc\s+rank\b/i,q{
data @P@a; do x=1 to @N@; output; end; run;
proc rank data=@P@a out=@P@b percent; var x; ranks percent; run;
proc sql; create table @P@o as select sum(percent) as actual from @P@b; quit;
},sub {50*($_[0]+1)});
family('transpose_name_metadata',qr/^\s*proc\s+transpose\b/i,q{
data @P@a; x=@N@; y=@NP1@; z=@NP2@; run;
proc transpose data=@P@a out=@P@b name=source prefix=val; var x y z; run;
proc sql; create table @P@o as select count(distinct source)+sum(val1) as actual from @P@b; quit;
},sub {3*$_[0]+6});
family('transpose_by_notsorted',qr/^\s*proc\s+transpose\b/i,q{
data @P@a; grp=1; value=@N@; output; grp=2; value=@NP1@; output; grp=1; value=@NP2@; output; run;
proc transpose data=@P@a out=@P@b prefix=val; by grp notsorted; var value; run;
proc sql; create table @P@o as select sum(val1)+count(*) as actual from @P@b; quit;
},sub {3*$_[0]+6});
family('datasets_change_member',qr/^\s*(?:proc\s+datasets|change)\b/i,q{
data @P@a; x=@N@; run;
proc datasets library=work nolist; change @P@a=@P@b; quit;
data @P@o; actual=@N@+exist('@P@a')+10*exist('@P@b'); run;
},sub {$_[0]+10});
family('datasets_modify_column',qr/^\s*(?:proc\s+datasets|modify)\b/i,q{
data @P@a; old=@N@; run;
proc datasets library=work nolist; modify @P@a; label old='New label'; rename old=new; quit;
data @P@o; length label $40; ds=open('@P@a','i'); num=varnum(ds,'new'); label=varlabel(ds,num); actual=@N@+num+lengthn(label); rc=close(ds); run;
},sub {$_[0]+10});
family('datasets_remove_format',qr/^\s*(?:proc\s+datasets|format)\b/i,q{
data @P@a; x=@N@; format x date9.; run;
proc datasets library=work nolist; modify @P@a; format x; quit;
proc contents data=@P@a out=@P@b noprint; run;
data @P@o; set @P@b; actual=@N@+missing(format); run;
},sub {$_[0]+1});
family('sql_order_calculated',qr/\bcalculated\b/i,q{
data @P@a; do x=1 to @N@; output; end; run;
proc sql; create table @P@b as select x,x*x as square from @P@a order by calculated square desc; quit;
data @P@o; set @P@b; if _n_=1; actual=x; run;
},sub {$_[0]},undef,$sql);
family('sql_ungrouped_having_remerge',qr/\bhaving\b/i,q{
data @P@a; do x=1 to @N@; output; end; run;
proc sql; create table @P@o as select x as actual from @P@a having x=max(x); quit;
},sub {$_[0]},undef,$sql);
family('failure_union_type_conflict',qr/\bunion\b/i,q{
data @P@a; x=@N@; run; data @P@b; length x $12; x='@N@'; run;
proc sql; create table @P@o as select x from @P@a union select x from @P@b; quit;
},undef,'(?:type|character|numeric|UNION)',$sql);
family('failure_update_missing_column',qr/^\s*update\b/i,q{
data @P@a; x=@N@; run;
proc sql; update @P@a set @P@absent=@N@; quit;
},undef,'Variable [A-Za-z0-9_]+ is not on file',$sql);
family('failure_character_length_limit',qr/^\s*length\b/i,q{
%let @P@len=%eval(32767+@N@);
data @P@a; length text $&@P@len; text='@N@'; run;
%symdel @P@len;
},undef,'length');
family('failure_rank_character_variable',qr/^\s*proc\s+rank\b/i,q{
data @P@a; length text $12; do j=1 to @N@; text='@N@'; output; end; run;
proc rank data=@P@a out=@P@b; var text; ranks position; run;
},undef,'(?:type|numeric)');
family('failure_print_missing_id',qr/^\s*proc\s+print\b/i,q{
data @P@a; do x=1 to @N@; output; end; run;
proc print data=@P@a; id @P@absent; var x; run;
},undef,'(?:not found|does not exist)');
Library_Evaluation_Corpus::write_corpus(library=>$books,destination=>$destination,round=>7,letter=>'B',start=>3001,
    families=>\@families,source_directories=>['.'],source_extension=>'txt',source_kind=>'book_sample',
    description=>'SAS book samples: DATA control/combination, statistical modeling, ODS capture, metadata and SQL; 450 successful and 50 intentional-error scenarios');
