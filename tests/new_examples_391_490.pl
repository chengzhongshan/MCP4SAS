use strict; use warnings;
my (@cases,$number); $number=390;
my %src=(include=>q{D:import_sas_macros_with_filename.sas},macro=>q{E:create_macro_vars_in_data_step_and_process_it_with_other_macro.sas},
 names=>q{E:rename_table_variable_name_has_spaces.sas},attrib=>q{E:format varibales in data step with attrib.sas},type=>q{D:check variable type with function vtype demo.sas},
 import=>q{E:firstobs not functional in Proc import but datarow works.sas},input=>q{E:infile and length_Only asign intended length of chr in statment LENGTH.sas},long=>q{E:read_long_line_into_dataset.sas},
 stop=>q{D:Stop function for infile to get specific lines.sas},scanover=>q{D:SAS data step scanover for specific rows.sas},format=>q{D:make dosage into hard call geno demo.sas},
 lib=>q{E:libname for path with space no need to escape in Linux.sas},directory=>q{D:Dir_existence_Template.sas},env=>q{D:SAS get System Path with Function sysget.sas},
 filter=>q{E:filter_data_step_records_with_mean_function_and_variable_shotcut.sas},sql=>q{D:Proc SQL aggregate functions need to be used with group and having function.sas},
 all=>q{D:Proc SQL subset number greate than all of number in a dataset.sas},max=>q{D:Proc SQL Max Demo.sas},modify=>q{D:Update, modify and alter in proct SQL.sas},
 delete=>q{D:Delete rows with where conditions in proc sql without create table.sas},round=>q{E:round_numeric_var_with_format_and_case_function_demo.sas},
 compare=>q{D:proc compare Comparing a Variable Multiple Times.sas},compareid=>q{D:proc compare to compare mult variables between two dsd with ID function.sas},
 append=>q{D:Use datastep Set function to append the same dataset.sas},regex=>q{E:prxmatch with perl regular expression and modifier.sas},
 corr=>q{E:Get corr P value based on Z, Get Z based on corr R, Get R based on Z.sas},logistic=>q{D:Logistic_regression_with_ROC_curve.sas},
 glm=>q{D:ods output proc glm statistics Demo.sas},survival=>q{D:proc lifttest Demo with ODS.sas},phreg=>q{D:proc phreg for survival analysis Demo.sas},
 meta=>q{D:Meta-analysis Demo.sas},binomial=>q{D:Pbinomal test with proc freq.sas},odds=>q{E:order_by_data_for_proc_freq_OR_calculation.sas},
 iml=>q{D:read matrix data, process it in iml, and export it into dataset.sas},imlnames=>q{D:IML use data to rename colname or rowname.sas},
 repeat=>q{D:Make matrix row_col Index with repeat and create sas dataset from IML matrix.sas},
 report=>q{D:proc report compuate newvar based on know vars.sas},links=>q{D:Proc report with multiple html links Demo.sas},
 heart=>q{E:draw_a_heart_using_proc_sgplot.sas},panel=>q{E:proc sgpanel to make multiple boxplots.sas},size=>q{E:custimze ods graphics output size.sas});
my $full=sub {my($name,$key,$body,$condition,%extra)=@_; my $id=''.++$number; $body=~s/\@T\@/e$id/g; $condition=~s/\@T\@/e$id/g if defined $condition;
 $body.="\ndata _null_; set e$id; if $condition then put 'MCP30_OK_$id'; else put 'ERROR: MCP30_ASSERT_$id'; run;\nproc print data=e$id; run;\n" if defined $condition;
 $body.=delete($extra{after})//'';
 push @cases,{id=>$id,name=>$name,source_ref=>$src{$key},description=>$condition//$name,sas=>$body,%extra};};
my $row=sub {my($n,$k,$b,$c,%x)=@_; $full->($n,$k,"data \@T\@; $b run;",$c,%x)};
# 391-400: escaped deferred includes, name literals and macro metadata.
$full->('dosubl_single_quoted_local_include','include',q{data _null_; rc=dosubl('%include ''@FIXTURE@'';'); run;},q{value=15},fixture=>q{data e391; value=15; run;});
$full->('execute_single_quoted_local_include','include',q{data _null_; call execute('%include ''@FIXTURE@'';'); run;},q{value=17},fixture=>q{data e392; value=17; run;});
$full->('validvarname_any_rename_space','names',q{options validvarname=any; data a; 'sample type'n=7; run; data @T@; set a; rename 'sample type'n=sample_type; run; options validvarname=v7;},q{sample_type=7});
$full->('name_literal_percent_is_not_macro','names',q{options validvarname=any; data @T@; '%e394_literal'n=9; value='%e394_literal'n; run;},q{value=9},forbid=>q{Injected targeted remote macro loader for: e394_literal},after=>q{options validvarname=v7;});
$full->('macro_dynamic_symputx_names','macro',q{data _null_; do i=1 to 3; call symputx(cats('e395_',i),i*i,'G'); end; run; data @T@; total=0; do i=1 to 3; total+input(symget(cats('e395_',i)),best32.); end; run;},q{total=14});
$full->('symexist_after_symdel','macro',q{%let e396var=present; %symdel e396var; data @T@; value=symexist('e396var'); run;},q{value=0});
$full->('dictionary_macros_custom_value','macro',q{%let e397custom=research; proc sql; create table @T@ as select value from dictionary.macros where name='E397CUSTOM' and scope='GLOBAL'; quit;},q{value='research'});
$row->('vtype_numeric_character','type',q{length text $8 nt ct $1; number=7; text='seven'; nt=vtype(number); ct=vtype(text);},q{nt='N' and ct='C'});
$row->('vlength_character_metadata','attrib',q{length text $23; text='short'; width=vlength(text); actual=lengthn(text);},q{width=23 and actual=5});
$row->('attrib_length_label_format','attrib',q{attrib x length=8 label='meaning' format=comma12.2; length labeltext formattext $30; x=10; labeltext=vlabel(x); formattext=vformat(x);},q{labeltext='meaning' and formattext='COMMA12.2'});
# 401-415: physical input, formats, WORK libraries and metadata.
$full->('import_datarow_skip_metadata','import',q{filename e401file temp; data _null_; file e401file; put 'metadata'; put 'a,4'; put 'b,7'; run; proc import datafile=e401file dbms=csv out=a replace; getnames=no; datarow=2; guessingrows=10; run; proc sql; create table @T@ as select sum(var2) as total,count(*) as n from a; quit; filename e401file clear;},q{total=11 and n=2});
$full->('infile_firstobs_skip_header','input',q{filename e402file temp; data _null_; file e402file; put 'header'; put '3'; put '5'; run; data a; infile e402file firstobs=2; input value; run; proc sql; create table @T@ as select sum(value) as total from a; quit; filename e402file clear;},q{total=8});
$full->('infile_obs_limit_records','input',q{filename e403file temp; data _null_; file e403file; do i=1 to 5; put i; end; run; data a; infile e403file obs=2; input value; run; proc sql; create table @T@ as select count(*) as n,sum(value) as total from a; quit; filename e403file clear;},q{n=2 and total=3});
$full->('infile_length_actual_record_bytes','long',q{filename e404file temp; data _null_; file e404file; put 'abc'; run; data @T@; infile e404file length=reclen truncover; input; n=reclen; run; filename e404file clear;},q{n=3});
$full->('infile_lrecl_long_record_scan','long',q{filename e405file temp lrecl=1000; data _null_; file e405file; length text $400; text=repeat('x',399); put text; run; data @T@; length text $500; infile e405file lrecl=1000 truncover; input text $char500.; n=lengthn(text); run; filename e405file clear;},q{n=400});
$full->('input_colon_character_no_truncation','input',q{data @T@; length key $30; input key :$30. value; datalines;
long_identifier 12
;
run;},q{key='long_identifier' and value=12});
$full->('stop_after_first_noncomment_record','stop',q{data @T@; length text $30; input text $char30.; if substr(text,1,1) ne '#' then do; output; stop; end; datalines;
# header
payload
unused
;
run;},q{text='payload'});
$full->('scanover_find_marker_in_record','scanover',q{filename e408file temp; data _null_; file e408file; put 'ignored'; put 'marker: 42'; run; data @T@; infile e408file scanover truncover; input @'marker:' value; run; filename e408file clear;},q{value=42});
$full->('format_dosage_threshold_ranges','format',q{proc format; value e409geno 0-.7=0 .7<-1.7=1 1.7<-2=2 other=-9; run; data @T@; a=input(put(.5,e409geno.),best32.); b=input(put(1.2,e409geno.),best32.); c=input(put(1.9,e409geno.),best32.); run;},q{a=0 and b=1 and c=2});
$full->('format_cntlin_dynamic_lookup','format',q{data control; length fmtname $8 type $1 label $12; fmtname='e410map'; type='N'; start=1; label='one'; output; start=2; label='two'; output; run; proc format cntlin=control; run; data @T@; length value $12; value=put(2,e410map.); run;},q{value='two'});
$full->('informat_cntlin_character_to_numeric','format',q{data control; length fmtname $8 type $1 start $8 label $8; fmtname='e411read'; type='I'; start='yes'; label='1'; output; start='no'; label='0'; output; run; proc format cntlin=control; run; data @T@; a=input('yes',e411read.); b=input('no',e411read.); run;},q{a=1 and b=0});
$full->('libname_owned_path_with_space','lib',q{data _null_; length path $1024; path=dcreate('e412 owned',pathname('work')); call symputx('e412path',path); run; libname ownlib "&e412path"; data ownlib.test; value=14; run; data @T@; set ownlib.test; run; proc datasets lib=ownlib nolist; delete test; quit; libname ownlib clear; data _null_; rc=filename('e412dir',symget('e412path')); rc=fdelete('e412dir'); rc=filename('e412dir'); run;},q{value=14});
$row->('directory_dopen_nonexistent_returns_zero','directory',q{rc=filename('e413dir',cats(pathname('work'),'/e413_missing')); handle=dopen('e413dir'); cleared=filename('e413dir');},q{handle=0 and cleared=0});
$row->('sysget_path_nonempty','env',q{length value $4000; value=sysget('PATH'); n=lengthn(value);},q{n>0});
$full->('filter_prefix_variable_mean','filter',q{data a; input a1 a2 a3; if mean(of a:)>3; datalines;
1 2 3
4 5 6
;
run; data @T@; set a; total=sum(of a1-a3); run;},q{total=15});
# 416-435: SQL grouped semantics and comparisons.
$full->('sql_having_group_sum_threshold','sql',q{data a; do grp=1 to 2; do x=1 to grp; output; end; end; run; proc sql; create table @T@ as select grp,sum(x) as total from a group by grp having calculated total>1; quit;},q{grp=2 and total=3});
$full->('sql_where_before_grouping','sql',q{data a; do grp=1 to 2; do x=1 to 3; output; end; end; run; proc sql; create table @T@ as select count(*) as n,sum(x) as total from a where x>=2; quit;},q{n=4 and total=10});
$full->('sql_greater_than_all_subquery','all',q{data a; do x=1 to 4; output; end; run; data b; do y=1,2; output; end; run; proc sql; create table @T@ as select count(*) as n,sum(x) as total from a where x>all(select y from b); quit;},q{n=2 and total=7});
$full->('sql_equal_any_subquery','all',q{data a; do x=1 to 4; output; end; run; data b; do y=2,4; output; end; run; proc sql; create table @T@ as select count(*) as n,sum(x) as total from a where x=any(select y from b); quit;},q{n=2 and total=6});
$full->('sql_not_in_subquery_filter','delete',q{data a; do x=1 to 4; output; end; run; data b; do y=1,4; output; end; run; proc sql; delete from a where x not in(select y from b); create table @T@ as select sum(x) as total from a; quit;},q{total=5});
$full->('sql_aggregate_then_scalar_max','max',q{data a; do x=2,4; output; end; run; proc sql; create table @T@ as select max(max(x),10) as value from a; quit;},q{value=10});
$full->('sql_group_count_distinct','sql',q{data a; do x=1,1,2,2,3; output; end; run; proc sql; create table @T@ as select count(*) as rows,count(distinct x) as uniquevals from a; quit;},q{rows=5 and uniquevals=3});
$full->('sql_alter_add_column_default','modify',q{data a; x=1; run; proc sql; alter table a add y num; update a set y=8; create table @T@ as select * from a; quit;},q{x=1 and y=8});
$full->('sql_alter_drop_column_metadata','modify',q{data a; x=1; y=2; run; proc sql; alter table a drop y; create table @T@ as select count(*) as n from dictionary.columns where libname='WORK' and memname='A'; quit;},q{n=1});
$full->('sql_insert_values_into_table','modify',q{proc sql; create table a(x num); insert into a values(4) values(9); create table @T@ as select count(*) as n,sum(x) as total from a; quit;},q{n=2 and total=13});
$full->('sql_update_case_by_row','modify',q{data a; do x=1 to 3; y=0; output; end; run; proc sql; update a set y=case when x=1 then 10 else 20 end; create table @T@ as select sum(y) as total from a; quit;},q{total=50});
$full->('sql_round_value_format_independent','round',q{data a; x=1.2345; run; proc sql; create table @T@ as select x format=8.2,round(x,.01) as rounded from a; quit;},q{abs(x-1.2345)<1e-10 and abs(rounded-1.23)<1e-10});
$full->('compare_absolute_tolerance_equal','compare',q{data a; x=1; run; data b; x=1.000001; run; proc compare base=a compare=b criterion=.00001 method=absolute noprint; run; %let e428code=&sysinfo; data @T@; value=input(symget('e428code'),best32.); run;},q{value=0});
$full->('compare_id_ignores_row_position','compareid',q{data a; do id=1 to 3; x=id*2; output; end; run; data b; do id=3 to 1 by -1; x=id*2; output; end; run; proc sort data=b; by id; run; proc compare base=a compare=b noprint; id id; run; %let e429code=&sysinfo; data @T@; value=input(symget('e429code'),best32.); run;},q{value=0});
$full->('compare_var_with_different_names','compare',q{data a; x=7; run; data b; y=7; run; proc compare base=a compare=b noprint; var x; with y; run; %let e430code=&sysinfo; data @T@; value=input(symget('e430code'),best32.); run;},q{value=0});
$full->('set_same_dataset_twice','append',q{data a; do value=1,2; output; end; run; data b; set a a; run; proc sql; create table @T@ as select count(*) as n,sum(value) as total from b; quit;},q{n=4 and total=6});
$full->('set_in_dataset_origin_flags','append',q{data a; x=4; run; data b; x=6; run; data calc; set a(in=froma) b(in=fromb); origin=froma+2*fromb; run; proc sql; create table @T@ as select sum(origin) as origins,sum(x) as total from calc; quit;},q{origins=3 and total=10});
$row->('prxmatch_case_insensitive_filter','regex',q{value=prxmatch('/(vom|nausea)/i','NAUSEA');},q{value=1});
$row->('prxmatch_negated_character_class','regex',q{value=prxmatch('/^[^0-9]+$/','alpha'); rejected=prxmatch('/^[^0-9]+$/','alpha2');},q{value=1 and rejected=0});
$full->('sql_like_literal_percent_single_quote','sql',q{data a; length label $8; do label='gene_a','other'; output; end; run; proc sql; create table @T@ as select count(*) as n from a where label like 'gene%'; quit;},q{n=1});
# 436-455: deterministic statistical procedure outputs and formulas.
$full->('corr_perfect_linear_outp','corr',q{data a; do x=1 to 5; y=3*x; output; end; run; proc corr data=a outp=c noprint; var x y; run; data @T@; set c; where _type_='CORR' and _name_='x'; value=y; run;},q{abs(value-1)<1e-10});
$full->('corr_covariance_sample_scale','corr',q{data a; do x=1 to 3; y=3*x; output; end; run; proc corr data=a cov outp=c noprint; var x y; run; data @T@; set c; where _type_='COV' and _name_='x'; value=y; run;},q{abs(value-3)<1e-10});
$full->('corr_spearman_reversed_order','corr',q{data a; do x=1 to 5; y=6-x; output; end; run; proc corr data=a spearman outs=c noprint; var x y; run; data @T@; set c; where _type_='CORR' and _name_='x'; value=y; run;},q{abs(value+1)<1e-10});
$full->('glm_solution_known_slope','glm',q{data a; do x=1 to 6; y=3+2*x; output; end; run; ods output ParameterEstimates=p; proc glm data=a; model y=x/solution; run; quit; ods output close; data @T@; set p; where parameter='x'; run;},q{abs(estimate-2)<1e-10});
$full->('glm_anova_degrees_of_freedom','glm',q{data a; do x=1 to 6; y=x+mod(x,2); output; end; run; ods output OverallANOVA=anova; proc glm data=a; model y=x; run; quit; ods output close; data @T@; set anova; where source='Error'; run;},q{df=4});
$full->('logistic_grouped_binomial_slope','logistic',q{data a; do x=-1 to 1; n=10; r=5+2*x; output; end; run; proc logistic data=a outest=est noprint; model r/n=x; run; data @T@; set est; run;},q{abs(intercept)<1e-5 and abs(x-log(7/3))<1e-5});
$full->('logistic_predicted_probabilities','logistic',q{data a; do x=-1 to 1; n=10; r=5+2*x; output; end; run; proc logistic data=a noprint; model r/n=x; output out=p pred=prob; run; proc sql; create table @T@ as select min(prob) as low,max(prob) as high from p; quit;},q{abs(low-.3)<1e-5 and abs(high-.7)<1e-5});
$full->('lifetest_uncensored_survival_endpoint','survival',q{data a; do time=1 to 4; status=1; output; end; run; proc lifetest data=a outsurv=s noprint; time time*status(0); run; proc sql; create table @T@ as select min(survival) as low,max(survival) as high from s; quit;},q{low=0 and high=1});
$full->('lifetest_stratified_output','survival',q{data a; do grp=1 to 2; do time=1 to 4; status=1; output; end; end; run; proc lifetest data=a outsurv=s noprint; time time*status(0); strata grp; run; proc sql; create table @T@ as select count(distinct grp) as groups from s; quit;},q{groups=2});
$full->('phreg_parameter_table_capture','phreg',q{data a; do i=1 to 30; x=mod(i,3); time=i; status=(mod(i,5) ne 0); output; end; run; ods output ParameterEstimates=p; proc phreg data=a; model time*status(0)=x; run; ods output close; proc sql; create table @T@ as select count(*) as n from p; quit;},q{n=1});
$row->('meta_inverse_variance_fixed_mean','meta',q{beta1=.2; beta2=.4; se1=.1; se2=.2; w1=1/se1**2; w2=1/se2**2; pooled=(w1*beta1+w2*beta2)/(w1+w2);},q{abs(pooled-.24)<1e-10});
$row->('meta_pooled_standard_error','meta',q{se=sqrt(1/(1/.1**2+1/.2**2));},q{abs(se-sqrt(.008))<1e-10});
$row->('meta_cochran_q_statistic','meta',q{pooled=.24; q=100*(.2-pooled)**2+25*(.4-pooled)**2;},q{abs(q-.8)<1e-10});
$row->('meta_i_squared_lower_bound','meta',q{q=.8; df=1; value=max(0,(q-df)/q);},q{value=0});
$row->('binomial_exact_symmetric_tail','binomial',q{value=cdf('binomial',2,.5,4);},q{abs(value-.6875)<1e-10});
$row->('binomial_probability_mass','binomial',q{value=pdf('binomial',2,.5,4);},q{abs(value-.375)<1e-10});
$row->('odds_ratio_cross_product','odds',q{a=8; b=2; c=4; d=6; ratio=a*d/(b*c);},q{ratio=6});
$row->('odds_log_standard_error','odds',q{se=sqrt(1/8+1/2+1/4+1/6);},q{abs(se-sqrt(25/24))<1e-10});
$row->('fisher_z_standard_error','corr',q{n=28; se=1/sqrt(n-3);},q{abs(se-.2)<1e-10});
$row->('correlation_t_statistic','corr',q{r=.5; n=14; t=r*sqrt((n-2)/(1-r*r));},q{abs(t-2)<1e-10});
# 456-465: IML indexing and reductions not used in prior batches.
for my $s (
 ['iml_repeat_row_pattern','repeat',q{a=repeat({1 2},3,1); rows=nrow(a); cols=ncol(a); total=sum(a);},q{rows=3 and cols=2 and total=9},'rows cols total'],
 ['iml_repeat_column_pattern','repeat',q{a=repeat({1,2},1,3); rows=nrow(a); cols=ncol(a); total=sum(a);},q{rows=2 and cols=3 and total=9},'rows cols total'],
 ['iml_diagonal_extraction','iml',q{a={1 2,3 4}; v=vecdiag(a); total=sum(v);},q{total=5},'total'],
 ['iml_diagonal_matrix_construction','iml',q{a=diag({2 3}); total=sum(a); value=a[1,2];},q{total=5 and value=0},'total value'],
 ['iml_row_mean_reduction','iml',q{a={1 3,5 7}; v=a[,:]; total=sum(v);},q{total=8},'total'],
 ['iml_column_mean_reduction','iml',q{a={1 3,5 7}; v=a[:,]; total=sum(v);},q{total=8},'total'],
 ['iml_matrix_transpose_contract','iml',q{a={1 2 3,4 5 6}; b=t(a); rows=nrow(b); cols=ncol(b); value=b[3,2];},q{rows=3 and cols=2 and value=6},'rows cols value'],
 ['iml_solve_linear_system','iml',q{a={2 1,1 2}; b={3,3}; x=solve(a,b); err=max(abs(x-1));},q{err<1e-10},'err'],
 ['iml_read_colname_metadata','imlnames',q{use e464base; read all var _num_ into a[colname=names]; close e464base; n=ncol(names)*nrow(names); value=a[1,2];},q{n=2 and value=8},'n value'],
 ['iml_export_named_columns','imlnames',q{a={2 4}; create e465out from a[colname={'leftcol' 'rightcol'}]; append from a; close e465out; value=sum(a);},q{value=6},'value']) {
 my($n,$k,$b,$c,$vars)=@$s; my $prefix=$n eq 'iml_read_colname_metadata' ? 'data e464base; x=4; y=8; run; ' : '';
 $full->($n,$k,$prefix."proc iml; $b create \@T\@ var {$vars}; append; close \@T\@; quit;",$c);
}
# 466-475: reports, panels and graphics with verified data.
$full->('report_group_sum_output','report',q{data a; grp=1; value=2; output; value=5; output; run; proc report data=a nowd out=rep; columns grp value; define grp/group; define value/analysis sum; run; data @T@; set rep; run;},q{value=7});
$full->('report_compute_percentage','report',q{data a; x=4; y=8; run; proc report data=a nowd out=rep; columns x y pct; define x/display; define y/display; define pct/computed; compute pct; pct=x/y*100; endcomp; run; data @T@; set rep; run;},q{pct=50});
$full->('report_url_call_define','links',q{data @T@; length gene $12; gene='TESTGENE'; run; proc report data=@T@ nowd; columns gene; define gene/display; compute gene; call define(_col_,'url','https://example.org/gene'); endcomp; run;},q{gene='TESTGENE'});
$full->('sgpanel_vbox_by_group','panel',q{data @T@; do grp=1 to 2; do value=1 to 5; output; end; end; run; proc sgpanel data=@T@; panelby grp; vbox value; run;},q{grp in(1,2) and value>=1 and value<=5});
$full->('sgpanel_scatter_by_panel','panel',q{data @T@; do grp=1 to 2; do x=1 to 3; y=x+grp; output; end; end; run; proc sgpanel data=@T@; panelby grp; scatter x=x y=y; run;},q{y=x+grp});
$full->('sgplot_heart_parametric_curve','heart',q{data @T@; do degree=0 to 360 by 10; t=degree*constant('pi')/180; x=16*sin(t)**3; y=13*cos(t)-5*cos(2*t)-2*cos(3*t)-cos(4*t); output; end; run; proc sgplot data=@T@; series x=x y=y; run;},q{abs(x)<=16.000001});
$full->('ods_graphics_explicit_size','size',q{ods graphics/width=4in height=3in; data @T@; do x=1 to 3; y=2*x; output; end; run; proc sgplot data=@T@; scatter x=x y=y; run; ods graphics/reset=all;},q{y=2*x});
$full->('sgplot_highlow_interval','size',q{data @T@; id=1; low=2; high=5; run; proc sgplot data=@T@; highlow x=id low=low high=high; run;},q{high-low=3});
$full->('sgplot_band_with_series','size',q{data @T@; do x=1 to 4; y=x; lower=y-.5; upper=y+.5; output; end; run; proc sgplot data=@T@; band x=x lower=lower upper=upper; series x=x y=y; run;},q{upper-lower=1});
$full->('sgplot_step_survival_shape','survival',q{data @T@; do time=0 to 4; survival=1-time/4; output; end; run; proc sgplot data=@T@; step x=time y=survival; run;},q{survival>=0 and survival<=1});
# 476-488: date, numeric, string and format contracts.
$row->('round_to_tenth','round',q{value=round(12.34,.1);},q{abs(value-12.3)<1e-10});
$row->('ceilz_integer_boundary','round',q{value=ceilz(2.01);},q{value=3});
$row->('floorz_negative_fraction','round',q{value=floorz(-2.01);},q{value=-3});
$row->('inputn_dynamic_date_informat','attrib',q{value=inputn('2026-10-13','yymmdd10.');},q{value='13oct2026'd});
$row->('putn_dynamic_zero_padded_format','format',q{length value $8; value=putn(7,'z4.');},q{value='0007'});
$row->('putc_dynamic_character_format','format',q{length value $12; value=putc('alpha','$upcase12.');},q{value='ALPHA'});
$row->('datdif_actual_day_count','attrib',q{value=datdif('01jan2024'd,'01mar2024'd,'ACT/ACT');},q{value=60});
$row->('yrdif_actual_year_fraction','attrib',q{value=yrdif('01jan2024'd,'01jan2025'd,'ACT/ACT');},q{abs(value-1)<1e-10});
$row->('anydigit_first_position','input',q{value=anydigit('abc7def');},q{value=4});
$row->('anyalpha_first_position','input',q{value=anyalpha('123x');},q{value=4});
$row->('notdigit_first_position','input',q{value=notdigit('123x');},q{value=4});
$row->('verify_allowed_character_set','regex',q{good=verify('ACGT','ACGT'); bad=verify('ACNX','ACGT');},q{good=0 and bad=3});
$row->('soundex_similar_names','regex',q{length a b $8; a=soundex('Robert'); b=soundex('Rupert');},q{a=b});
# 489-490: failures which must remain failures.
$full->('unsorted_by_input_failure','compareid',q{data a; do id=2,1; value=id; output; end; run; data bad; set a; by id; run;},undef,fail=>1,diagnostic=>q{not properly sorted});
$full->('sql_where_aggregate_failure','sql',q{data a; do value=1 to 3; output; end; run; proc sql; create table bad as select * from a where sum(value)>2; quit;},undef,fail=>1,diagnostic=>q{(?:Summary functions|summary function)});
die 'Expected exactly 100 cases ending at 490' unless @cases==100 && $number==490;
return \@cases;
