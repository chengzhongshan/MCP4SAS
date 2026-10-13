use strict;
use warnings;
my @batch;
my $add = sub {
    my ($id, $name, $description, $sas, %extra) = @_;
    push @batch, {id=>$id, name=>$name, description=>$description, sas=>$sas, %extra};
};
$add->('31', 'datalines_apostrophe', 'An apostrophe in raw inline data is data, not a SAS quoted-string opener.', <<'SAS');
data e31; length surname $30; input id surname $; datalines;
1 O'Brien
2 Smith
;
data _null_; set e31; if id=1 then do;
if surname="O'Brien" then put 'MCP30_OK_31'; else put 'ERROR: MCP30_ASSERT_31'; end; run;
proc print data=e31; run;
SAS
$add->('32', 'datalines4_comment_tokens', 'Raw DATALINES4 fields preserve comment delimiters and semicolons.', <<'SAS');
data e32; length token $40; infile datalines4 delimiter='|' truncover; input id token $; datalines4;
1|*/literal
2|text;with;semicolons
3|/*literal
;;;;
data _null_; set e32 end=last; retain good 0;
good+(id=1 and token='*/literal') or (id=2 and token='text;with;semicolons') or (id=3 and token='/*literal');
if last then do; if good=3 then put 'MCP30_OK_32'; else put 'ERROR: MCP30_ASSERT_32'; end; run;
proc print data=e32; run;
SAS
$add->('33', 'sort_duplicate_keys', 'NODUPKEY retains three unique keys and two rejected rows.', <<'SAS');
data e33; input id value; datalines;
2 20
1 10
2 21
3 30
1 11
;
proc sort data=e33 out=e33unique dupout=e33dup nodupkey; by id; run;
proc sql noprint; select count(*) into :e33n from e33unique; select count(*) into :e33d from e33dup; quit;
data _null_; if &e33n=3 and &e33d=2 then put 'MCP30_OK_33'; else put 'ERROR: MCP30_ASSERT_33'; run;
proc print data=e33unique; run;
SAS
$add->('34', 'sql_union_semantics', 'UNION removes duplicates; UNION ALL preserves them.', <<'SAS');
data e34a; do value=1 to 2; output; end; run;
data e34b; do value=2 to 3; output; end; run;
proc sql; create table e34unique as select value from e34a union select value from e34b;
create table e34all as select value from e34a union all select value from e34b;
select count(*) into :e34u from e34unique; select count(*) into :e34a from e34all; quit;
data _null_; if &e34u=3 and &e34a=4 then put 'MCP30_OK_34'; else put 'ERROR: MCP30_ASSERT_34'; run;
SAS
$add->('35', 'regex_variant_extraction', 'PRX extracts an rsID embedded in annotation text.', <<'SAS');
data e35; length annotation $60 rsid $20; annotation='gene=ABC;variant=rs123456;build=37';
rx=prxparse('/variant=(rs[0-9]+)/'); if prxmatch(rx,annotation) then rsid=prxposn(rx,1,annotation); run;
data _null_; set e35; if rsid='rs123456' then put 'MCP30_OK_35'; else put 'ERROR: MCP30_ASSERT_35'; run;
proc print data=e35; run;
SAS
$add->('36', 'leap_day_date_import', 'YYMMDD date informat preserves leap day and computes a one-day difference.', <<'SAS');
data e36; date=input('2024-02-29',yymmdd10.); next=input('2024-03-01',yymmdd10.); format date next yymmdd10.; run;
data _null_; set e36; if day(date)=29 and next-date=1 then put 'MCP30_OK_36'; else put 'ERROR: MCP30_ASSERT_36'; run;
proc print data=e36; run;
SAS
$add->('37', 'numeric_function_missing', 'MEAN ignores a missing argument while arithmetic propagation does not.', <<'SAS');
data e37; a=4; b=.; c=8; available_mean=mean(a,b,c); raw_mean=(a+b+c)/3; run;
data _null_; set e37; if available_mean=6 and missing(raw_mean) then put 'MCP30_OK_37'; else put 'ERROR: MCP30_ASSERT_37'; run;
proc print data=e37; run;
SAS
$add->('38', 'retained_group_totals', 'BY-group accumulation resets at group boundaries.', <<'SAS');
data e38; input group value; datalines;
1 2
1 3
2 7
2 4
;
data e38total; set e38; by group; if first.group then total=0; total+value; if last.group; run;
data _null_; set e38total end=last; retain good 0; good+(group=1 and total=5) or (group=2 and total=11);
if last then do; if good=2 then put 'MCP30_OK_38'; else put 'ERROR: MCP30_ASSERT_38'; end; run;
proc print data=e38total; run;
SAS
$add->('39', 'month_end_alignment', 'INTNX aligns a January date to the leap-year February month end.', <<'SAS');
data e39; start='15JAN2024'd; finish=intnx('month',start,1,'end'); format start finish date9.; run;
data _null_; set e39; if finish='29FEB2024'd then put 'MCP30_OK_39'; else put 'ERROR: MCP30_ASSERT_39'; run;
proc print data=e39; run;
SAS
$add->('40', 'univariate_percentile', 'PROC UNIVARIATE computes median 5 for values 1 through 9.', <<'SAS');
data e40; do value=1 to 9; output; end; run;
proc univariate data=e40; var value; output out=e40pct pctlpts=50 pctlpre=q; run;
data _null_; set e40pct; if q50=5 then put 'MCP30_OK_40'; else put 'ERROR: MCP30_ASSERT_40'; run;
SAS
$add->('41', 'paired_ttest_output', 'Paired TTEST produces a finite probability.', <<'SAS');
data e41; input before after; datalines;
10 12
11 14
9 10
12 14
8 11
;
ods output TTests=e41tests;
proc ttest data=e41; paired after*before; run;
data _null_; set e41tests; if 0<=probt and probt<=1 then put 'MCP30_OK_41'; else put 'ERROR: MCP30_ASSERT_41'; run;
SAS
$add->('42', 'anova_overall_table', 'PROC GLM emits an overall ANOVA table for a generated factor.', <<'SAS');
data e42; do group=1 to 3; do replicate=1 to 4; response=group*3+replicate; output; end; end; run;
ods output OverallANOVA=e42anova;
proc glm data=e42; class group; model response=group; quit;
proc sql noprint; select count(*) into :e42n from e42anova; quit;
data _null_; if &e42n=3 then put 'MCP30_OK_42'; else put 'ERROR: MCP30_ASSERT_42'; run;
SAS
$add->('43', 'correlation_output_dataset', 'PROC CORR returns Pearson correlation 1 for a deterministic linear pair.', <<'SAS');
data e43; do x=1 to 8; y=5+2*x; output; end; run;
proc corr data=e43 outp=e43corr; var x y; run;
data _null_; set e43corr; if _type_='CORR' and _name_='x' then do;
if abs(y-1)<1e-10 then put 'MCP30_OK_43'; else put 'ERROR: MCP30_ASSERT_43'; end; run;
SAS
$add->('44', 'fisher_exact_output', 'Fisher exact test exposes its ODS result table.', <<'SAS');
data e44; input treatment outcome count; datalines;
0 0 8
0 1 2
1 0 3
1 1 7
;
ods output FishersExact=e44exact;
proc freq data=e44; tables treatment*outcome / fisher; weight count; run;
proc sql noprint; select count(*) into :e44n from e44exact; quit;
data _null_; if &e44n>0 then put 'MCP30_OK_44'; else put 'ERROR: MCP30_ASSERT_44'; run;
SAS
$add->('45', 'kaplan_meier_output', 'LIFETEST emits bounded nonmissing survival estimates.', <<'SAS');
data e45; input duration censored; datalines;
1 0
2 0
3 1
4 0
5 1
;
proc lifetest data=e45 outsurv=e45surv plots=none; time duration*censored(1); run;
proc sql noprint; select count(*),sum(survival<0 or survival>1) into :e45n,:e45bad
from e45surv where not missing(survival); quit;
data _null_; if &e45n>0 and &e45bad=0 then put 'MCP30_OK_45'; else put 'ERROR: MCP30_ASSERT_45'; run;
SAS
$add->('46', 'poisson_genmod_parameters', 'GENMOD Poisson fit estimates nonmissing intercept and slope.', <<'SAS');
data e46; input x count; datalines;
0 1
0 2
1 2
1 3
2 4
2 5
3 6
3 7
;
ods output ParameterEstimates=e46params;
proc genmod data=e46; model count=x / dist=poisson link=log; run;
proc sql noprint; select count(*),sum(missing(estimate)) into :e46n,:e46bad from e46params where parameter in ('Intercept','x'); quit;
data _null_; if &e46n=2 and &e46bad=0 then put 'MCP30_OK_46'; else put 'ERROR: MCP30_ASSERT_46'; run;
SAS
$add->('47', 'mixed_model_fixed_effects', 'MIXED random-intercept model returns two fixed-effect estimates.', <<'SAS');
data e47; do subject=1 to 6; do visit=0 to 2; response=10+2*visit+subject+0.2*mod(subject*visit,3); output; end; end; run;
ods output SolutionF=e47fixed;
proc mixed data=e47; class subject; model response=visit / solution; random intercept / subject=subject; run;
proc sql noprint; select count(*),sum(missing(estimate)) into :e47n,:e47bad from e47fixed; quit;
data _null_; if &e47n=2 and &e47bad=0 then put 'MCP30_OK_47'; else put 'ERROR: MCP30_ASSERT_47'; run;
SAS
$add->('48', 'sql_case_missing_category', 'CASE labels a missing score separately from numeric categories.', <<'SAS');
data e48; input id score; datalines;
1 .
2 3
3 9
;
proc sql; create table e48labels as select id,case when missing(score) then 'unknown'
when score<5 then 'low' else 'high' end as category from e48; quit;
data _null_; set e48labels end=last; retain good 0;
good+(id=1 and category='unknown') or (id=2 and category='low') or (id=3 and category='high');
if last then do; if good=3 then put 'MCP30_OK_48'; else put 'ERROR: MCP30_ASSERT_48'; end; run;
proc print data=e48labels; run;
SAS
$add->('49', 'fcmp_custom_function', 'FCMP compiles and executes a generated custom function.', <<'SAS');
proc fcmp outlib=work.e49funcs.math;
function e49squareplus(x); return(x*x+1); endsub; run;
options cmplib=work.e49funcs;
data e49; value=e49squareplus(6); run;
data _null_; set e49; if value=37 then put 'MCP30_OK_49'; else put 'ERROR: MCP30_ASSERT_49'; run;
proc print data=e49; run; options cmplib=();
SAS
$add->('50', 'tabulate_multidimensional_table', 'TABULATE completes a generated two-dimensional summary.', <<'SAS');
data e50; do group=1 to 2; do visit=1 to 3; value=group*visit; output; end; end; run;
proc tabulate data=e50; class group visit; var value; table group,visit*value*sum; run;
proc sql noprint; select sum(value) into :e50sum from e50; quit;
data _null_; if &e50sum=18 then put 'MCP30_OK_50'; else put 'ERROR: MCP30_ASSERT_50'; run;
SAS
$add->('51', 'temporary_array_dot_product', 'Temporary-array coefficients produce dot product 32.', <<'SAS');
data e51; array coefficient[3] _temporary_ (2 3 4); array value[3] v1-v3 (1 2 6);
total=0; do i=1 to dim(value); total+coefficient[i]*value[i]; end; run;
data _null_; set e51; if total=32 then put 'MCP30_OK_51'; else put 'ERROR: MCP30_ASSERT_51'; run;
proc print data=e51; run;
SAS
$add->('52', 'lag_by_group_reset', 'LAG executes on every row and resets the first value within a group.', <<'SAS');
data e52; input group value; datalines;
1 10
1 14
2 50
2 59
;
data e52lag; set e52; by group; previous=lag(value); if first.group then previous=.; difference=value-previous; run;
data _null_; set e52lag end=last; retain good 0;
good+(group=1 and value=14 and difference=4) or (group=2 and value=59 and difference=9);
if last then do; if good=2 then put 'MCP30_OK_52'; else put 'ERROR: MCP30_ASSERT_52'; end; run;
proc print data=e52lag; run;
SAS
$add->('53', 'format_cntlin_lookup', 'CNTLIN builds a format from a generated lookup table.', <<'SAS');
data e53format; length fmtname $12 type $1 label $20; fmtname='e53code'; type='N';
start=1; label='control'; output; start=2; label='case'; output; run;
proc format cntlin=e53format; run;
data e53; id=2; label=put(id,e53code.); run;
data _null_; set e53; if label='case' then put 'MCP30_OK_53'; else put 'ERROR: MCP30_ASSERT_53'; run;
proc print data=e53; run;
SAS
$add->('54', 'dictionary_column_metadata', 'DICTIONARY.COLUMNS reports one numeric and one character column.', <<'SAS');
data e54; length text $17; id=1; text='metadata'; run;
proc sql; create table e54meta as select name,type,length from dictionary.columns where libname='WORK' and memname='E54';
select count(*),sum(type='char' and length=17),sum(type='num') into :e54n,:e54char,:e54num from e54meta; quit;
data _null_; if &e54n=2 and &e54char=1 and &e54num=1 then put 'MCP30_OK_54'; else put 'ERROR: MCP30_ASSERT_54'; run;
SAS
$add->('55', 'contents_variable_order', 'CONTENTS output preserves variable order metadata.', <<'SAS');
data e55; z=1; a=2; m=3; run;
proc contents data=e55 out=e55meta varnum; run;
proc sql noprint; select count(*) into :e55good from e55meta
where (name='z' and varnum=1) or (name='a' and varnum=2) or (name='m' and varnum=3); quit;
data _null_; if &e55good=3 then put 'MCP30_OK_55'; else put 'ERROR: MCP30_ASSERT_55'; run;
SAS
$add->('56', 'space_in_name_literal', 'VALIDVARNAME=ANY supports a column name containing a space.', <<'SAS');
options validvarname=any;
data e56; 'patient id'n=56; measurement=7; run;
data _null_; set e56; if 'patient id'n=56 then put 'MCP30_OK_56'; else put 'ERROR: MCP30_ASSERT_56'; run;
proc print data=e56; run; options validvarname=v7;
SAS
$add->('57', 'special_missing_values', 'MISSING recognizes .A while ordinary equality distinguishes it from dot.', <<'SAS');
data e57; ordinary=.; special=.A; is_missing=missing(special); differs=(special ne ordinary); run;
data _null_; set e57; if is_missing=1 and differs=1 then put 'MCP30_OK_57'; else put 'ERROR: MCP30_ASSERT_57'; run;
proc print data=e57; run;
SAS
$add->('58', 'missing_infile_resource', 'DATA-step input from a nonexistent WORK file must fail.', <<'SAS', fail=>1, diagnostic=>'Physical file does not exist|does not exist');
filename e58file "%sysfunc(pathname(work))/mcp30_e58_never_created.txt";
data e58; infile e58file; input value; run; filename e58file clear;
SAS
$add->('59', 'sql_unknown_column', 'SQL referencing an unknown column must fail.', <<'SAS', fail=>1, diagnostic=>'not found|could not be found');
data e59; known=1; run;
proc sql; select unknown_column from e59; quit;
SAS
$add->('60', 'array_subscript_bounds', 'Out-of-range DATA-step array access must fail at runtime.', <<'SAS', fail=>1, diagnostic=>'Array subscript out of range');
data e60; array values[2] a b (10 20); i=3; result=values[i]; run;
SAS
return \@batch;
