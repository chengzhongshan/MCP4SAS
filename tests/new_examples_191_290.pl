use strict;
use warnings;
my (@cases,$number); $number=190;
my %src=(
 quote=>q{D:nrstr qcmpres cmpres demo.sas}, bquote=>q{D:Resolve Macro varible with _bquote_ and _str_ in SAS Macro.sas},
 symget=>q{D:symget functions like that of a hash.sas}, dosubl=>q{D:Run macro repeatedly with macro dosubl.sas},
 cards=>q{E:datalines4 demo.sas}, regex=>q{E:prxposn need to be used with prxparse and prxmatch.sas},
 sets=>q{D:Proc SQL Except  Union Union all Intersect Demo.sas}, join=>q{D:Proc SQL Full Join with Function Coalesce.sas},
 dup=>q{E:Be caution about Proc SQL Left Join when there are duplicates in the right table.sas},
 update=>q{D:Proc SQL update Demo.sas}, view=>q{D:Proc SQL View Demo.sas}, case=>q{D:Proc SQL with conditions by using case function.sas},
 having=>q{D:Proc SQL function Group with having conditions.sas}, delete=>q{D:Proc SQL delete Demo.sas},
 mean=>q{E:different usage of avg and mean in proc sql.sas}, merge=>q{E:Merge Function IMPORTANT NOTES.sas},
 lag=>q{E:lag_with_by_and_last_statement.sas}, first=>q{E:output_first_and_last_record_by_grp_at_the_same_row.sas},
 array=>q{D:temporary numeric array.sas}, miss=>q{D:specify mssing types in data step.sas},
 select=>q{D:Select When function in data step.sas}, append=>q{D:Proc Append Demo.sas},
 contents=>q{D:Proc contents output variable information without ODS print.sas},
 nobs=>q{D:Retrieve the number of observations in a dataset.sas}, exist=>q{D:Verifying the existence of a SAS dataset.sas},
 dirs=>q{D:SAS file function dopen dnum dread Demo.sas}, rename=>q{D:Rename file, dataset and directory Demo.sas},
 create=>q{E:create dir in sas data step with dcreate.sas}, rank=>q{E:proc rank with tiers.sas},
 std=>q{E:colwide z score with proc standard.sas}, range=>q{E:scale data to range with proc stdize but not proc standard.sas},
 reg=>q{D:output residual in proc reg for simple regression.sas}, wilcox=>q{D:Wilcoxon rank sum test_Mann Whitney U test Demo.sas},
 transpose=>q{D:SAS transpose long to wide and wide to long Demo Very useful.sas}, compare=>q{D:Compare two datasets with Proc compare.sas},
 multtest=>q{D:Proc Multtest for P value adjustment.sas}, fdr=>q{D:simple FDR for raw P values.sas},
 cmiss=>q{E:cmiss_function2get_missing_variables_among_variables.sas}, iml=>q{E:get_index_for_nonmissing_values_in_proc_iml.sas},
 fcmp=>q{D:proc fcmp Demo.sas}, ods=>q{D:ODS alternative for NOPRINT.sas},
 recover=>q{E:recover ods with ods select all after using ods select none.sas},
 freq=>q{E:ODS output Tables failed with noprint in Proc Freq.sas}, report=>q{D:HTML output with Proc report Demo_create link for all elements in columns.sas},
 plot=>q{D:proc sgplot demo.sas}, missing=>q{D:SAS Function Missing and IFC Demo.sas}, date=>q{D:time format with do loop.sas},
 alphabet=>q{E:assign_number_to_alphabet_word.sas}, replace=>q{E:prxchange_replace_elements_within_multiple_quotes.sas});
my $full=sub {
    my ($name,$key,$body,$condition,%extra)=@_;
    my $id=''.++$number; $body =~ s/\@T\@/e$id/g;
    $condition =~ s/\@T\@/e$id/g if defined $condition;
    $body .= "\ndata _null_; set e$id; if $condition then put 'MCP30_OK_$id'; else put 'ERROR: MCP30_ASSERT_$id'; run;\nproc print data=e$id; run;\n" if defined $condition;
    push @cases,{id=>$id,name=>$name,source_ref=>$src{$key},description=>$condition//$name,sas=>$body,%extra};
};
my $row=sub {my ($n,$k,$b,$c,%x)=@_; $full->($n,$k,"data \@T\@; $b run;",$c,%x)};
# 191-200: new macro and literal contexts, not numeric variants of old cases.
$full->('nested_nrstr_inside_bquote','quote',q{%let e191text=%bquote(%nrstr(%e191_literal())); data @T@; length value $80; value=symget('e191text'); run;},q{value='%e191_literal()'},forbid=>q{Injected targeted remote macro loader for: e191_literal});
$full->('nrstr_inside_evaluated_double_quote','quote',q{data @T@; length value $80; value="%nrstr(%e192_literal())"; run;},q{value='%e192_literal()'},forbid=>q{Injected targeted remote macro loader for: e192_literal});
$full->('macro_quote_escaped_double_quote','bquote',q{%let e193text=%str(%"); data @T@; length value $4; value=symget('e193text'); run;},q{value='"'});
$full->('superq_masked_comma_arguments','quote',q{%let e194text=left,right; %macro e194take(x); data @T@; length value $40; value=symget('x'); run; %mend; %e194take(%superq(e194text));},q{value='left,right'});
$full->('symget_dynamic_lookup','symget',q{%let e195_low=11; %let e195_high=23; data @T@; length key $32; total=0; do key='e195_low','e195_high'; total+input(symget(key),best32.); end; run;},q{total=34});
$full->('symputx_local_scope','symget',q{%let e196value=outer; %macro e196scope; %local e196value; data _null_; call symputx('e196value','inner','L'); run; data @T@; length value $10; value=symget('e196value'); run; %mend; %e196scope;},q{value='inner' and symget('e196value')='outer'});
$full->('dosubl_synchronous_result','dosubl',q{%macro e197set; %global e197value; %let e197value=42; %mend; data @T@; rc=dosubl('%e197set;'); value=input(symget('e197value'),best32.); run;},q{rc=0 and value=42});
$full->('cards4_embedded_macro_tokens','cards',q{data e198raw; length text $80; infile datalines4 truncover; input text $char80.; datalines4;
alpha;beta %e198_literal() 'unmatched
;;;;
run; data @T@; set e198raw; n=lengthn(text); run;},q{n=37},forbid=>q{Injected targeted remote macro loader for: e198_literal});
$row->('regex_literal_percent_dependency','regex',q{length value $30; value=prxchange('s/%e199_literal/foo/',1,'%e199_literal');},q{value='foo'},forbid=>q{Injected targeted remote macro loader for: e199_literal});
$full->('macro_nrstr_comment_like_text','quote',q{%let e200text=%nrstr(/*literal*/ alpha;); data @T@; length value $80; value=symget('e200text'); run;},q{index(value,'alpha;')>0});
# 201-220: SQL set, join, update, grouping and view semantics.
my $tables=q{data leftbase; do id=1,2,2; output; end; run; data rightbase; do id=2,3; output; end; run;};
for my $spec (
 ['sql_union_distinct','union',3,6],['sql_union_all_bag','union all',5,10],
 ['sql_except_distinct','except',1,1],['sql_intersect_distinct','intersect',1,2],
 ['sql_except_all_bag','except all',2,3],['sql_intersect_all_bag','intersect all',1,2]) {
 my($n,$op,$cnt,$total)=@$spec;
 $full->($n,'sets',$tables."proc sql; create table calc as select id from leftbase $op select id from rightbase; create table \@T\@ as select count(*) as n,sum(id) as total from calc; quit;","n=$cnt and total=$total");
}
$full->('sql_full_join_coalesced_key','join',q{data a; id=1; a=10; output; id=2; a=20; output; run; data b; id=2; b=200; output; id=3; b=300; output; run; proc sql; create table calc as select coalesce(a.id,b.id) as id,a.a,b.b from a full join b on a.id=b.id; create table @T@ as select count(*) as n,sum(id) as total,sum(a) as av,sum(b) as bv from calc; quit;},q{n=3 and total=6 and av=30 and bv=500});
$full->('sql_duplicate_right_join_multiplicity','dup',q{data a; id=1; run; data b; id=1; do value=4,5; output; end; run; proc sql; create table @T@ as select count(*) as n,sum(b.value) as total from a left join b on a.id=b.id; quit;},q{n=2 and total=9});
$full->('sql_not_exists_antijoin','join',$tables.q{proc sql; create table @T@ as select count(*) as n,sum(id) as total from leftbase a where not exists(select * from rightbase b where a.id=b.id); quit;},q{n=1 and total=1});
$full->('sql_correlated_update','update',q{data a; do id=1 to 3; value=0; output; end; run; data b; id=2; value=17; run; proc sql; update a set value=(select value from b where a.id=b.id) where exists(select * from b where a.id=b.id); create table @T@ as select sum(value) as total,count(*) as n from a; quit;},q{total=17 and n=3});
$full->('sql_delete_subset','delete',q{data a; do id=1 to 5; output; end; run; proc sql; delete from a where mod(id,2)=0; create table @T@ as select count(*) as n,sum(id) as total from a; quit;},q{n=3 and total=9});
$full->('sql_view_reads_updated_base','view',q{data a; value=2; run; proc sql; create view ev as select value*3 as answer from a; update a set value=7; create table @T@ as select * from ev; drop view ev; quit;},q{answer=21});
$full->('sql_case_nullable_category','case',q{data a; do x=.,0,5; output; end; run; proc sql; create table calc as select case when missing(x) then 'absent' when x=0 then 'zero' else 'positive' end as label from a; create table @T@ as select count(distinct label) as n from calc; quit;},q{n=3});
$full->('sql_having_only_singletons','having',$tables.q{proc sql; create table calc as select id from leftbase group by id having count(*)=1; create table @T@ as select count(*) as n,min(id) as value from calc; quit;},q{n=1 and value=1});
$full->('sql_column_mean_missing_denominator','mean',q{data a; do x=2,.,8; output; end; run; proc sql; create table @T@ as select avg(x) as value,count(x) as nonmissing,count(*) as allrows from a; quit;},q{value=5 and nonmissing=2 and allrows=3});
$full->('sql_row_mean_multiple_arguments','mean',q{data a; x=2; y=8; output; x=.; y=6; output; run; proc sql; create table calc as select mean(x,y) as value from a; create table @T@ as select sum(value) as total,count(*) as n from calc; quit;},q{total=11 and n=2});
$full->('sql_calculated_alias_filter','case',q{data a; do x=1 to 4; output; end; run; proc sql; create table calc as select x,x*x as square from a where calculated square>8; create table @T@ as select sum(square) as total from calc; quit;},q{total=25});
$full->('sql_outer_union_corr_columns','sets',q{data a; x=1; y=2; run; data b; y=3; z=4; run; proc sql; create table calc as select * from a outer union corr select * from b; create table @T@ as select count(*) as n,sum(y) as total from calc; quit;},q{n=2 and total=5});
$full->('sql_left_join_unmatched_missing','join',q{data a; do id=1 to 2; output; end; run; data b; id=2; value=9; run; proc sql; create table @T@ as select sum(missing(b.value)) as n,sum(coalesce(b.value,0)) as total from a left join b on a.id=b.id; quit;},q{n=1 and total=9});
$full->('sql_select_into_trimmed_list','contents',q{data a; do id=1 to 3; output; end; run; proc sql noprint; select id into :e220list separated by '|' from a order by id descending; quit; data @T@; length value $20; value=symget('e220list'); run;},q{value='3|2|1'});
# 221-230: merge queues, arrays, missing values and append.
$full->('merge_last_dataset_overwrites','merge',q{data a; id=1; value=10; run; data b; id=1; value=20; run; data @T@; merge a b; by id; run;},q{value=20});
$full->('merge_in_flags_inner_only','merge',q{data a; do id=1 to 3; output; end; run; data b; do id=2 to 4; output; end; run; data calc; merge a(in=ina) b(in=inb); by id; if ina and inb; run; proc sql; create table @T@ as select count(*) as n,sum(id) as total from calc; quit;},q{n=2 and total=5});
$full->('conditional_lag_queue','lag',q{data calc; do x=1 to 4; if mod(x,2)=0 then prior=lag(x); output; end; run; proc sql; create table @T@ as select max(prior) as value,count(prior) as n from calc; quit;},q{value=2 and n=1});
$full->('by_group_lag_reset','lag',q{data a; do grp=1 to 2; do x=1 to 2; output; end; end; run; data calc; set a; by grp; prior=lag(x); if first.grp then prior=.; run; proc sql; create table @T@ as select sum(prior) as total,count(prior) as n from calc; quit;},q{total=2 and n=2});
$full->('by_first_last_bounds','first',q{data a; do grp=1 to 2; do x=1 to 3; output; end; end; run; data calc; set a; by grp; retain firstvalue; if first.grp then firstvalue=x; if last.grp then output; run; proc sql; create table @T@ as select sum(x-firstvalue) as total,count(*) as n from calc; quit;},q{total=4 and n=2});
$row->('temporary_array_retention','array',q{array acc[2] _temporary_ (0 0); do iteration=1 to 3; acc[1]+iteration; acc[2]+2; end; a=acc[1]; b=acc[2];},q{a=6 and b=6});
$row->('character_array_lookup_order','alphabet',q{array words[3] $8 _temporary_ ('gamma','alpha','beta'); length value $8; value=words[2];},q{value='alpha'});
$row->('special_missing_comparison_order','miss',q{value=(.A<.Z and .Z<0 and .<.A); n=nmiss(.A,.Z,0);},q{value=1 and n=2});
$row->('select_when_default_category','select',q{length country $12 label $10; country='UNKNOWN'; select(country); when('CANADA') label='CA'; otherwise label='other'; end;},q{label='other'});
$full->('append_force_extra_variable','append',q{data a; x=1; run; data b; x=2; extra=9; run; proc append base=a data=b force; run; proc sql; create table @T@ as select count(*) as n,sum(x) as total from a; quit;},q{n=2 and total=3},warning=>1,diagnostic=>q{not found on BASE});
# 231-240: metadata and owned WORK filesystem operations.
$full->('contents_variable_type_counts','contents',q{data a; length text $7; number=1; text='a'; run; proc contents data=a out=meta noprint; run; proc sql; create table @T@ as select count(*) as n,sum(type=2) as chars,max(length) as width from meta; quit;},q{n=2 and chars=1 and width=8});
$full->('dataset_nlobs_handle_closed','nobs',q{data a; do x=1 to 4; output; end; run; data @T@; dsid=open('a'); n=attrn(dsid,'NLOBS'); rc=close(dsid); run;},q{n=4 and rc=0});
$full->('view_exist_type_selector','exist',q{data a; x=1; run; proc sql; create view ev as select * from a; quit; data @T@; isview=exist('ev','VIEW'); isdata=exist('ev','DATA'); run; proc sql; drop view ev; quit;},q{isview=1 and isdata=0});
$full->('missing_dataset_open_returns_zero','exist',q{data @T@; dsid=open('work.e234_missing','I'); msg=symget('SYSERRORTEXT'); run;},q{dsid=0});
$row->('work_directory_handle_lifecycle','dirs',q{rc=filename('e235dir',pathname('work')); did=dopen('e235dir'); opened=(did>0); n=dnum(did); closed=dclose(did); cleared=filename('e235dir');},q{opened=1 and n>=0 and closed=0 and cleared=0});
$full->('work_owned_directory_create_remove','create',q{data @T@; length path $1024; path=dcreate('e236_owned',pathname('work')); rc=filename('e236dir',path); exists=fexist('e236dir'); deleted=fdelete('e236dir'); cleared=filename('e236dir'); run;},q{lengthn(path)>0 and exists=1 and deleted=0});
$full->('work_file_rename_verified','rename',q{filename e237old "%sysfunc(pathname(work))/e237_old.txt"; data _null_; file e237old; put 'owned'; run; data @T@; length old new $1024; old=pathname('e237old'); new=cats(pathname('work'),'/e237_new.txt'); rc=rename(old,new,'file'); assigned=filename('e237new',new); exists=fexist('e237new'); deleted=fdelete('e237new'); run; filename e237old clear; filename e237new clear;},q{rc=0 and exists=1 and deleted=0});
$full->('dataset_rename_function','rename',q{data e238old; value=7; run; data _null_; rc=rename('work.e238old','e238new'); run; data @T@; set e238new; existsold=exist('e238old'); run;},q{value=7 and existsold=0});
$full->('contents_label_format_preservation','contents',q{data a; x=1; label x='library value'; format x comma12.2; run; proc contents data=a out=meta noprint; run; data @T@; set meta; run;},q{label='library value' and format='COMMA' and formatl=12 and formatd=2});
$full->('dictionary_columns_work_lookup','contents',q{data e240lookup; length word $12; x=1; run; proc sql; create table @T@ as select count(*) as n,max(length) as width from dictionary.columns where libname='WORK' and memname='E240LOOKUP'; quit;},q{n=2 and width=12});
# 241-260: rank, scale, regress, transpose, comparison and multiplicity.
for my $spec (['rank_ties_low','low',1],['rank_ties_high','high',2],['rank_ties_mean','mean',1.5],['rank_ties_dense','dense',1]) {
 my($n,$ties,$expected)=@$spec;
 $full->($n,'rank',"data a; do x=1,1,4; output; end; run; proc rank data=a out=calc ties=$ties; var x; ranks r; run; proc sql; create table \@T\@ as select min(r) as value from calc; quit;","value=$expected");
}
$full->('rank_groups_zero_based','rank',q{data a; do x=1 to 4; output; end; run; proc rank data=a out=calc groups=2; var x; ranks r; run; proc sql; create table @T@ as select min(r) as low,max(r) as high,sum(r) as total from calc; quit;},q{low=0 and high=1 and total=2});
$full->('standard_sample_zscores','std',q{data a; do x=2,4,6; output; end; run; proc standard data=a out=calc mean=0 std=1; var x; run; proc sql; create table @T@ as select sum(x) as total,min(x) as low,max(x) as high from calc; quit;},q{abs(total)<1e-10 and abs(low+1)<1e-10 and abs(high-1)<1e-10});
$full->('stdize_range_endpoints','range',q{data a; do x=2,4,10; output; end; run; proc stdize data=a out=calc method=range; var x; run; proc sql; create table @T@ as select min(x) as low,max(x) as high,sum(x) as total from calc; quit;},q{low=0 and high=1 and abs(total-1.25)<1e-10});
$full->('reg_perfect_line_residuals','reg',q{data a; do x=1 to 5; y=2+3*x; output; end; run; proc reg data=a noprint; model y=x; output out=calc r=resid p=pred; quit; proc sql; create table @T@ as select max(abs(resid)) as maxerr,count(pred) as n from calc; quit;},q{maxerr<1e-10 and n=5});
$full->('reg_outest_intercept_slope','reg',q{data a; do x=1 to 6; y=5-2*x; output; end; run; proc reg data=a outest=est noprint; model y=x; quit; data @T@; set est; run;},q{abs(intercept-5)<1e-10 and abs(x+2)<1e-10});
$full->('wilcoxon_two_group_ods_capture','wilcox',q{data a; do grp=1 to 2; do i=1 to 4; x=i+grp; output; end; end; run; ods output WilcoxonTest=wc; proc npar1way data=a wilcoxon; class grp; var x; run; ods output close; proc sql; create table @T@ as select count(*) as n from wc; quit;},q{n>0});
$full->('transpose_wide_to_long_names','transpose',q{data a; id=1; x=4; y=8; run; proc transpose data=a out=calc; by id; var x y; run; proc sql; create table @T@ as select count(*) as n,sum(col1) as total,count(distinct _name_) as names from calc; quit;},q{n=2 and total=12 and names=2});
$full->('transpose_long_to_wide_id','transpose',q{data a; length key $4; id=1; key='x'; value=4; output; key='y'; value=8; output; run; proc transpose data=a out=@T@; by id; id key; var value; run;},q{x=4 and y=8});
$full->('transpose_let_duplicate_last','transpose',q{data a; id=1; value=4; output; value=9; output; run; proc transpose data=a out=@T@ let prefix=v; id id; var value; run;},q{v1=9},warning=>1,diagnostic=>q{occurs twice});
$full->('compare_equal_sysinfo','compare',q{data a; x=2; run; data b; set a; run; proc compare base=a compare=b noprint; run; %let e254code=&sysinfo; data @T@; value=input(symget('e254code'),best32.); run;},q{value=0});
$full->('compare_unequal_sysinfo','compare',q{data a; x=2; run; data b; x=3; run; proc compare base=a compare=b noprint; run; %let e255code=&sysinfo; data @T@; value=input(symget('e255code'),best32.); run;},q{value>0});
$full->('multtest_bonferroni_raw_p','multtest',q{data pvals; do raw_p=.01,.04,.20; output; end; run; proc multtest inpvalues=pvals bon out=adjusted noprint; run; proc sql; create table @T@ as select min(bon_p) as low,max(bon_p) as high from adjusted; quit;},q{abs(low-.03)<1e-10 and abs(high-.60)<1e-10});
$full->('fdr_manual_monotone_stepup','fdr',q{data pvals; do p=.01,.04,.20; output; end; run; proc sort data=pvals; by descending p; run; data calc; set pvals; retain bound 1; rank=4-_n_; bound=min(bound,p*3/rank); run; proc sql; create table @T@ as select min(bound) as low,max(bound) as high from calc; quit;},q{abs(low-.03)<1e-10 and abs(high-.20)<1e-10});
$row->('cmiss_mixed_types','cmiss',q{length a b $8; a=''; b='x'; x=.; y=7; n=cmiss(a,b,x,y);},q{n=2});
$full->('iml_nonmissing_mask_count','iml',q{proc iml; a={1 . 3, . 5 6}; n=sum(a^=.); create @T@ var {n}; append; close @T@; quit;},q{n=4});
$full->('fcmp_work_function','fcmp',q{proc fcmp outlib=work.e260funcs.math; function e260square(x); return(x*x); endsub; quit; options cmplib=work.e260funcs; data @T@; value=e260square(7); run; options cmplib=();},q{value=49});
# 261-270: ODS suppression, capture and graphics using synthetic data.
$full->('ods_select_none_capture_moments','ods',q{data a; do x=1 to 4; output; end; run; ods select none; ods output Moments=mom; proc univariate data=a; var x; run; ods output close; ods select all; proc sql; create table @T@ as select count(*) as n from mom; quit;},q{n>0});
$full->('ods_recover_after_freq_suppression','recover',q{data a; do x=1,1,2; output; end; run; ods select none; proc freq data=a; tables x; run; ods select all; data @T@; value=1; run;},q{value=1});
$full->('freq_ods_crosstab_capture','freq',q{data a; do grp=1 to 2; do x=1 to 2; output; end; end; run; ods output CrossTabFreqs=ct; proc freq data=a; tables grp*x; run; ods output close; proc sql; create table @T@ as select count(*) as n from ct; quit;},q{n=9});
$full->('freq_noprint_ods_missing_warning','freq',q{data a; do x=1,2; output; end; run; ods output OneWayFreqs=e264lost; proc freq data=a noprint; tables x; run; ods output close; data @T@; captured=exist('e264lost'); run;},q{captured=0},warning=>1,diagnostic=>q{not created});
$full->('report_nowd_computed_column','report',q{data a; x=3; y=4; run; proc report data=a nowd out=rep; columns x y total; define x/display; define y/display; define total/computed; compute total; total=x+y; endcomp; run; data @T@; set rep; run;},q{total=7});
$full->('sgplot_scatter_group','plot',q{data @T@; do grp=1 to 2; do x=1 to 3; y=x*grp; output; end; end; run; proc sgplot data=@T@; scatter x=x y=y/group=grp; run;},q{y=x*grp});
$full->('sgplot_series_sorted','plot',q{data @T@; do x=1 to 5; y=x*x; output; end; run; proc sgplot data=@T@; series x=x y=y; run;},q{y=x*x});
$full->('sgplot_histogram_density','plot',q{data @T@; do x=1 to 20; output; end; run; proc sgplot data=@T@; histogram x; density x; run;},q{x>=1 and x<=20});
$full->('sgplot_vbar_response_sum','plot',q{data @T@; do grp=1 to 2; do value=1 to 3; output; end; end; run; proc sgplot data=@T@; vbar grp/response=value stat=sum; run;},q{value>=1 and value<=3});
$full->('sgplot_refline_and_inset','plot',q{data @T@; do x=1 to 3; y=x; output; end; run; proc sgplot data=@T@; scatter x=x y=y; refline 2/axis=y; inset 'library validation'; run;},q{x=y});
# 271-280: text/regular-expression operations and missing conditionals.
$row->('prxposn_capture_numeric_suffix','regex',q{length value $20; re=prxparse('/^gene_(\d+)$/'); matched=prxmatch(re,'gene_42'); value=prxposn(re,1,'gene_42'); call prxfree(re);},q{matched=1 and value='42'});
$row->('prxsubstr_match_position_length','regex',q{re=prxparse('/\d+/'); call prxsubstr(re,'abc123def',pos,len); call prxfree(re);},q{pos=4 and len=3});
$row->('prxnext_multiple_matches','regex',q{re=prxparse('/\d+/'); start=1; stop=length('a12b345'); total=0; call prxnext(re,start,stop,'a12b345',pos,len); do while(pos>0); total+len; call prxnext(re,start,stop,'a12b345',pos,len); end; call prxfree(re);},q{total=5});
$row->('prxchange_reverse_capture_order','replace',q{length value $40; value=prxchange('s/(\w+),(\w+)/$2:$1/',1,'alpha,beta');},q{value='beta:alpha'});
$row->('prxchange_remove_quote_pairs','replace',q{length value $40; value=prxchange('s/"([^\"]+)"/$1/',-1,'"one" "two"');},q{value='one two'});
$row->('ifc_missing_third_branch','missing',q{length value $20; value=ifc(.,'yes','no','missing');},q{value='missing'});
$row->('coalescec_first_nonblank','missing',q{length value $20; value=coalescec('','alpha','beta');},q{value='alpha'});
$row->('missing_numeric_char_combination','missing',q{n=missing(.Z)+missing(' ')+missing(0)+missing('0');},q{n=2});
$row->('vvalue_formatted_numeric_text','contents',q{length value $20; x=1234.5; format x comma12.1; value=strip(vvalue(x));},q{value='1,234.5'});
$row->('vname_array_index_metadata','array',q{array items[2] alpha beta; length value $20; value=vname(items[2]);},q{upcase(value)='BETA'});
# 281-290: time/date units, views, and genuinely failed source patterns.
$row->('intck_month_discrete_continuous','date',q{a=intck('month','31jan2024'd,'01feb2024'd); b=intck('month','31jan2024'd,'01feb2024'd,'continuous');},q{a=1 and b=0});
$row->('intnx_leap_day_alignment','date',q{value=intnx('month','15jan2024'd,1,'end');},q{value='29feb2024'd});
$row->('dhms_datepart_timepart_roundtrip','date',q{stamp=dhms('13oct2026'd,14,25,30); d=datepart(stamp); t=timepart(stamp);},q{d='13oct2026'd and t=14*3600+25*60+30});
$row->('mdy_leap_year_construct','date',q{value=mdy(2,29,2024); y=year(value); m=month(value); d=day(value);},q{y=2024 and m=2 and d=29});
$row->('date_informat_iso_roundtrip','date',q{length value $20; d=input('2026-10-13',yymmdd10.); value=put(d,yymmdd10.);},q{value='2026-10-13'});
$full->('do_date_loop_day_step','date',q{data calc; do day='01jan2024'd to '15jan2024'd by 7; output; end; run; proc sql; create table @T@ as select count(*) as n,max(day)-min(day) as span from calc; quit;},q{n=3 and span=14});
$full->('data_step_view_reexecution','view',q{data a; x=2; run; data ev/view=ev; set a; value=x*2; run; data a; x=7; run; data @T@; set ev; run; proc datasets lib=work nolist; delete ev/memtype=view; quit;},q{value=14});
$full->('transpose_duplicate_id_failure','transpose',q{data a; id=1; value=2; output; value=3; output; run; proc transpose data=a out=bad; id id; var value; run;},undef,fail=>1,diagnostic=>q{occurs twice});
$full->('sql_ambiguous_column_failure','join',q{data a; id=1; run; data b; id=1; run; proc sql; create table bad as select id from a inner join b on a.id=b.id; quit;},undef,fail=>1,diagnostic=>q{ambiguous});
$full->('undefined_word_function_failure','alphabet',q{data bad; value=word(3); run;},undef,fail=>1,diagnostic=>q{WORD.*unknown});
die 'Expected 100 cases ending at 290, got '.scalar(@cases).' / '.$number unless @cases==100 && $number==290;
return \@cases;
