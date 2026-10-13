use strict; use warnings;
my (@cases,$number); $number=490;
my %src=(quotes=>q{E:Add quote to separate var list.sas},cat=>q{E:CAT CATX for Linking variables to create new one in PROC SQL.sas},
 sort=>q{E:desending should put ahead of the variable used in proc sort.sas},hold=>q{E:evaluate_single_and_double_at_in_data_step.sas},
 having=>q{E:Get_minimum_or_max_value_for_any_of_specific_columns_with_having.sas},lag=>q{E:lag_generate_missing_values.sas},
 matrix=>q{E:make data step matrix with array.sas},global=>q{E:make_global_macro_var_with_symputx_to_overwrite_macro_vars.sas},
 duplicates=>q{E:OUTPUT duplicates into sas dataset.sas},perm=>q{E:ranperm_generate_random_matrix.sas},range=>q{E:scale ssGSEA score in the range from -1 to 1.sas},
 strip=>q{E:strip left for equal condition in proc sql.sas},symput=>q{E:symputx demo different from symput.sas},
 colon=>q{E:Tell_sas_to_read_var_in_variable_length.sas},prx=>q{E:use prxmatch in sysfunc.sas},binary=>q{E:use_binary_function_in_proc_iml_generate_SNP_haplotype.sas},
 repeat=>q{D:A macro to Run other Macro repeatedly.sas},dict=>q{D:check tables with dictionary.tables by proc sql.sas},
 array=>q{D:Datastep Array function to make multiple new variables and assign initial value to it.sas},set=>q{D:Datastep Set demo.sas},
 by=>q{D:Demo for data step retain, by, if condition to summarize data.sas},until=>q{D:Do until Demo.sas},work=>q{D:get sas work dir with sysfunc pathname_work.sas},
 cmpres=>q{D:Macro function cmpres and qcmpres.sas},multi=>q{D:Make multiple macro variables with Function array and call symput in data step.sas},
 retain=>q{D:Powerful Function retain in datasetp.sas},join=>q{D:Proc Import only import partial column variables and rename them steamlessly.sas},
 rank=>q{D:Proc Rank Demo.sas},cats=>q{D:Proc SQL with Cats and other Cat functions.sas},
 transpose=>q{D:Proc transpose_transpose rowwide long data into columnwide long data.sas},split=>q{D:split_elements_and_output_ids_into_each_row.sas},
 amp=>q{D:tell sas to read variable until there are two or more spaces as a delimeter.sas},point=>q{D:Transform Plink Tped to long format for SAS with point function debugging.sas},
 min=>q{D:use_scan_countc_to_get_min_value_with_loop.sas},heat=>q{D:Heatmap Demo.sas},gtl=>q{D:GTL Demo very useful.sas},
 render=>q{D:Proc sgrender with proc template Demo.sas},bar=>q{D:sgplot  vbar with mean by using response stat group functions.sas},
 tmpl=>q{D:Get template code with proc sgplot function tmplout.sas},compare=>q{D:Proc compare with var and id as well as output parameters.sas});
my $full=sub {my($name,$key,$body,$condition,%extra)=@_; my $id=''.++$number;
 $body=~s/\@T\@/e$id/g; $condition=~s/\@T\@/e$id/g if defined $condition;
 $body.="\ndata _null_; set e$id; if $condition then put 'MCP30_OK_$id'; else put 'ERROR: MCP30_ASSERT_$id'; run;\nproc print data=e$id; run;\n" if defined $condition;
 push @cases,{id=>$id,name=>$name,source_ref=>$src{$key},description=>$condition//$name,sas=>$body,%extra};};
my $row=sub {my($n,$k,$b,$c,%x)=@_; $full->($n,$k,"data \@T\@; $b run;",$c,%x)};
# 491-500: quoted dependency lists and macro scope.
$full->('include_two_quoted_local_files','quotes',q{%include '@FIXTURE_1@' '@FIXTURE_2@'; data @T@; set e491a; set e491b; total=a+b; run;},q{total=29},fixtures=>[q{data e491a; a=12; run;},q{data e491b; b=17; run;}]);
$full->('dosubl_two_quoted_local_files','quotes',q{data _null_; rc=dosubl('%include ''@FIXTURE_1@'' ''@FIXTURE_2@'';'); run; data @T@; set e492a; set e492b; total=a*b; run;},q{total=42},fixtures=>[q{data e492a; a=6; run;},q{data e492b; b=7; run;}]);
$full->('macro_quote_word_list','quotes',q{%let e493list=alpha beta gamma; %let e493quoted=%sysfunc(prxchange(s/ +/","/,-1,&e493list)); data @T@; length text $60; text=cats('"',symget('e493quoted'),'"'); run;},q{text='"alpha","beta","gamma"'});
$full->('symputx_global_overwrites_shadow','global',q{%let e494v=4; %macro e494m; %local e494v; %let e494v=9; data _null_; call symputx('e494v',21,'G'); run; %mend; %e494m; data @T@; value=&e494v; run;},q{value=21});
$full->('symputx_local_preserves_global','symput',q{%let e495v=8; %macro e495m; %local e495v; data _null_; call symputx('e495v',13,'L'); run; data @T@; local_value=&e495v; run; %mend; %e495m; data @T@; set @T@; global_value=&e495v; run;},q{local_value=13 and global_value=8});
$full->('symputx_numeric_trim','symput',q{data _null_; call symputx('e496v',1234); run; data @T@; length text $20; text=symget('e496v'); n=lengthn(text); run;},q{text='1234' and n=4});
$full->('macro_repeat_parameter_bound','repeat',q{%macro e497m(n); %do j=1 %to &n; data e497part&j; value=&j*3; run; %end; %mend; %e497m(4); data a; set e497part1-e497part4; run; proc sql; create table @T@ as select count(*) as n,sum(value) as total from a; quit;},q{n=4 and total=30});
$full->('cmpres_reduces_internal_blanks','cmpres',q{%let e498v=%cmpres(  five     plus    ten ); data @T@; length text $30; text=symget('e498v'); run;},q{text='five plus ten'});
$full->('array_symputx_cutpoints','multi',q{data _null_; array q[3] _temporary_ (2.5 5 7.5); do i=1 to 3; call symputx(cats('e499q',i),q[i],'G'); end; run; data @T@; total=&e499q1+&e499q2+&e499q3; run;},q{total=15});
$full->('sysfunc_prxparse_then_match','prx',q{%let e500re=%sysfunc(prxparse(/^[A-Z]{2}[0-9]{3}$/)); %let e500match=%sysfunc(prxmatch(&e500re,AB123)); data @T@; value=&e500match; run; %syscall prxfree(e500re);},q{value=1});
# 501-515: input pointers and delimited text.
$full->('single_at_rereads_same_record','hold',q{data @T@; input first @; input second third; total=first+second+third; datalines;
2 5 9
;
run;},q{total=16});
$full->('double_at_paired_values','hold',q{data a; input key value @@; datalines;
1 3 2 8 3 13
;
run; proc sql; create table @T@ as select count(*) as n,sum(key*value) as total from a; quit;},q{n=3 and total=58},quality=>1,diagnostic=>q{SAS went to a new line when INPUT statement reached past the end of a line});
$full->('colon_reads_tab_separated_identifier','colon',q{data @T@; length gene $24; infile datalines dlm='09'x; input gene :$24. value; datalines;
long_gene_name	18
;
run;},q{gene='long_gene_name' and value=18});
$full->('ampersand_reads_two_word_name','amp',q{data @T@; input id name & $30. score; datalines;
1 Ada Lovelace  28
;
run;},q{name='Ada Lovelace' and score=28});
$full->('ampersand_colon_multiple_spaces','amp',q{data @T@; length label $30; input label & $30. value; datalines;
single label   35
;
run;},q{label='single label' and value=35});
$full->('scan_split_comma_ids','split',q{data a; length ids $30 item $12; ids='rs4,rs9,rs12'; do i=1 to countw(ids,','); item=scan(ids,i,','); output; end; run; proc sql; create table @T@ as select count(*) as n,sum(lengthn(item)) as width from a; quit;},q{n=3 and width=10});
$row->('scan_min_explicit_numeric_conversion','min',q{length text $30; text='8,2,11,-3'; value=constant('big'); do i=1 to countc(text,',')+1; value=min(value,input(scan(text,i,','),best32.)); end;},q{value=-3});
$row->('scan_max_negative_tokens','min',q{length text $30; text='-8,-2,-11'; value=-constant('big'); do i=1 to countw(text,','); value=max(value,input(scan(text,i,','),best32.)); end;},q{value=-2});
$row->('scan_preserves_empty_field_m','split',q{length text $20 middle $8; text='a,,c'; middle=scan(text,2,',','m'); n=countw(text,',','m');},q{missing(middle) and n=3});
$row->('qscan_retains_embedded_comma','split',q{length text $40 item $20; text='"a,b",c'; item=dequote(scan(text,1,',','q'));},q{item='a,b'});
$full->('infile_column_pointer_reposition','hold',q{data @T@; input @1 first 2. @5 second 2.; total=first+second; datalines;
12  34
;
run;},q{total=46});
$full->('input_absolute_pointer_character','colon',q{data @T@; input @1 prefix $3. @5 value 3.; datalines;
ABC 127
;
run;},q{prefix='ABC' and value=127});
$row->('countw_quoted_delimiters','split',q{n=countw('alpha,"beta,gamma",delta',',','q');},q{n=3});
$row->('scan_backward_last_token','min',q{length text $20 last $8; text='4,9,16'; last=scan(text,-1,','); value=input(last,best32.);},q{value=16});
$row->('trimmed_sql_key_preparation','strip',q{length raw clean $12; raw='  A12'; clean=strip(left(raw)); n=lengthn(clean);},q{clean='A12' and n=3});
# 516-535: arrays, retained values, permutations and indexing.
$row->('array_two_dimensional_trace','matrix',q{array m[2,2] m1-m4 (3 4 5 6); trace=m[1,1]+m[2,2];},q{trace=9});
$row->('array_temporary_lower_bound_zero','array',q{array a[0:3] _temporary_ (2 4 6 8); lower=lbound(a); value=0; do i=lbound(a) to hbound(a); value+a[i]; end;},q{value=20 and lower=0});
$row->('array_character_initial_values','array',q{array a[3] $8 c1-c3 ('red' 'green' 'blue'); length value $30; value=catx('/',of a[*]);},q{value='red/green/blue'});
$row->('array_parallel_scale_columns','matrix',q{array a[3] x1-x3 (2 4 8); array b[3] y1-y3; do i=1 to dim(a); b[i]=a[i]/2; end; total=sum(of b[*]);},q{total=7});
$row->('do_until_executes_once','until',q{value=0; do until(value>=10); value+3; end;},q{value=12});
$row->('do_while_zero_iterations','until',q{value=12; n=0; do while(value<10); n+1; value+1; end;},q{value=12 and n=0});
$row->('do_until_fibonacci_threshold','until',q{a=0; b=1; n=0; do until(b>=20); next=a+b; a=b; b=next; n+1; end;},q{a=13 and b=21 and n=7});
$full->('retain_prefix_running_total','retain',q{data a; do x=2 to 8 by 2; output; end; run; data b; set a; retain total 0; total=total+x; run; data @T@; set b end=last; if last; run;},q{total=20});
$full->('by_reset_group_running_total','by',q{data a; do grp=1 to 2; do x=1 to 3; output; end; end; run; data b; set a; by grp; if first.grp then total=0; total+x; if last.grp; run; proc sql; create table @T@ as select sum(total) as value,count(*) as n from b; quit;},q{value=12 and n=2});
$full->('lag_unconditional_difference','lag',q{data a; do x=3 to 12 by 3; output; end; run; data b; set a; previous=lag(x); if _n_>1 then difference=x-previous; run; proc sql; create table @T@ as select sum(difference) as total,sum(missing(previous)) as first_missing from b; quit;},q{total=9 and first_missing=1});
$full->('lag_conditional_queue_semantics','lag',q{data a; do x=1 to 6; output; end; run; data b; set a; if mod(x,2)=0 then previous=lag(x); run; proc sql; create table @T@ as select sum(previous) as total from b; quit;},q{total=6});
$row->('ranperm_preserves_integer_multiset','perm',q{array a[5] x1-x5 (1 2 3 4 5); seed=19283; call ranperm(seed,of a[*]); total=sum(of a[*]); product=x1*x2*x3*x4*x5;},q{total=15 and product=120});
$row->('fisher_yates_permutation_unique','perm',q{array a[6] x1-x6 (1 2 3 4 5 6); call streaminit(771); do i=6 to 2 by -1; j=ceil(rand('uniform')*i); temp=a[i]; a[i]=a[j]; a[j]=temp; end; total=sum(of a[*]); product=x1*x2*x3*x4*x5*x6;},q{total=21 and product=720});
$row->('binary_three_bit_decode','binary',q{array bit[3] b1-b3; value=5; do i=1 to 3; power=2**(3-i); bit[i]=floor(value/power); value=value-bit[i]*power; end; reconstructed=4*b1+2*b2+b3;},q{b1=1 and b2=0 and b3=1 and reconstructed=5});
$row->('binary_bitwise_operations','binary',q{intersection=band(6,3); union=bor(6,3); difference=bxor(6,3);},q{intersection=2 and union=7 and difference=5});
$full->('point_read_reverse_order','point',q{data a; do x=1 to 4; output; end; run; data b; do p=4 to 1 by -1; set a point=p; output; end; stop; run; data @T@; set b; if _n_=1; run;},q{x=4});
$full->('point_repeat_selected_observation','point',q{data a; x=5; output; x=9; output; run; data b; p=2; do repeat=1 to 3; set a point=p; output; end; stop; run; proc sql; create table @T@ as select count(*) as n,sum(x) as total from b; quit;},q{n=3 and total=27});
$full->('set_in_flags_origin_counts','set',q{data a; x=2; output; x=4; output; run; data b; x=7; output; run; data c; set a(in=left) b(in=right); origin=left+2*right; run; proc sql; create table @T@ as select sum(origin) as origins,sum(x) as total from c; quit;},q{origins=4 and total=13});
$full->('set_dataset_keep_rename','set',q{data a; x=7; unused=9; run; data @T@; set a(keep=x rename=(x=value)); doubled=value*2; run;},q{value=7 and doubled=14});
$full->('set_obs_firstobs_window','set',q{data a; do x=1 to 8; output; end; run; data b; set a(firstobs=3 obs=5); run; proc sql; create table @T@ as select count(*) as n,sum(x) as total from b; quit;},q{n=3 and total=12});
# 536-555: SQL, sorted duplicates and ranking.
$full->('sort_descending_first_row','sort',q{data a; do x=1 to 4; output; end; run; proc sort data=a; by descending x; run; data @T@; set a; if _n_=1; run;},q{x=4});
$full->('sort_mixed_direction_by_groups','sort',q{data a; do grp=2 to 1 by -1; do x=1 to 3; output; end; end; run; proc sort data=a; by grp descending x; run; data @T@; set a; if _n_=1; run;},q{grp=1 and x=3});
$full->('sort_dupout_count_and_value','duplicates',q{data a; input id value; datalines;
1 10
1 20
2 30
2 40
;
run; proc sort data=a nodupkey dupout=b; by id; run; proc sql; create table @T@ as select count(*) as n,sum(value) as total from b; quit;},q{n=2 and total=60});
$full->('sort_noduprecs_entire_row','duplicates',q{data a; input id value; datalines;
1 10
1 10
1 20
;
run; proc sort data=a noduprecs; by _all_; run; proc sql; create table @T@ as select count(*) as n,sum(value) as total from a; quit;},q{n=2 and total=30});
$full->('sql_having_multi_column_minima','having',q{data a; input id p q; datalines;
1 3 8
2 1 7
3 4 2
;
run; proc sql; create table b as select * from a having p=min(p) or q=min(q); create table @T@ as select count(*) as n,sum(id) as ids from b; quit;},q{n=2 and ids=5});
$full->('sql_having_group_max_ties','having',q{data a; input grp value; datalines;
1 3
1 3
1 2
2 7
;
run; proc sql; create table b as select * from a group by grp having value=max(value); create table @T@ as select count(*) as n,sum(value) as total from b; quit;},q{n=3 and total=13});
$full->('sql_catx_chromosome_position','cat',q{data a; chr=3; position=127; run; proc sql; create table @T@ as select catx(':',put(chr,best12.),put(position,best12.)) as locus length=30 from a; quit;},q{locus='3:127'});
$full->('sql_cats_padded_character_parts','cats',q{data a; length year month $8; year=' 2026'; month=' 10'; run; proc sql; create table @T@ as select cats(year,month) as value length=20 from a; quit;},q{value='202610'});
$full->('sql_cat_preserves_internal_blanks','cat',q{data a; length x y $3; x='A'; y='B'; run; proc sql; create table @T@ as select cat(x,y) as value length=6 from a; quit;},q{value='A  B'});
$full->('sql_join_trimmed_keys','strip',q{data a; length key $12; key='  abc'; value=11; run; data b; length key $12; key='abc'; value=17; run; proc sql; create table @T@ as select a.value+b.value as total from a join b on strip(a.key)=strip(b.key); quit;},q{total=28});
$full->('sql_full_join_coalesce_key','join',q{data a; id=1; value=5; run; data b; id=2; value=8; run; proc sql; create table c as select coalesce(a.id,b.id) as id,coalesce(a.value,b.value) as value from a full join b on a.id=b.id; create table @T@ as select sum(id) as ids,sum(value) as total from c; quit;},q{ids=3 and total=13});
$full->('sql_left_join_missing_match','join',q{data a; do id=1 to 3; output; end; run; data b; id=2; value=7; run; proc sql; create table c as select a.id,b.value from a left join b on a.id=b.id; create table @T@ as select count(*) as n,sum(missing(value)) as unmatched from c; quit;},q{n=3 and unmatched=2});
$full->('rank_ties_low_group','rank',q{data a; input x; datalines;
3
3
9
;
run; proc rank data=a out=b ties=low; var x; ranks r; run; proc sql; create table @T@ as select sum(r) as total from b; quit;},q{total=5});
$full->('rank_ties_high_group','rank',q{data a; input x; datalines;
3
3
9
;
run; proc rank data=a out=b ties=high; var x; ranks r; run; proc sql; create table @T@ as select sum(r) as total from b; quit;},q{total=7});
$full->('rank_descending_highest_first','rank',q{data a; do x=2 to 6 by 2; output; end; run; proc rank data=a out=b descending; var x; ranks r; run; data @T@; set b; where x=6; run;},q{r=1});
$full->('sql_range_scaling_signed','range',q{data a; input x; datalines;
2
5
8
;
run; proc sql; create table b as select 2*(x-min(x))/(max(x)-min(x))-1 as scaled from a; create table @T@ as select min(scaled) as low,max(scaled) as high,sum(scaled) as total from b; quit;},q{low=-1 and high=1 and abs(total)<1e-12});
$full->('stdize_range_then_signed_scale','range',q{data a; input x; datalines;
10
20
30
;
run; proc stdize data=a out=b method=range; var x; run; proc sql; create table @T@ as select min(2*x-1) as low,max(2*x-1) as high from b; quit;},q{low=-1 and high=1});
$full->('sql_dictionary_specific_member','dict',q{data e553source; value=4; run; proc sql; create table @T@ as select nobs,nvar from dictionary.tables where libname='WORK' and memname='E553SOURCE' and memtype='DATA'; quit;},q{nobs=1 and nvar=1});
$full->('sql_dictionary_column_order','dict',q{data e554source; length label $8; value=3; label='data'; run; proc sql; create table @T@ as select name,varnum,length from dictionary.columns where libname='WORK' and memname='E554SOURCE' and name='label'; quit;},q{varnum=1 and length=8});
$row->('work_directory_exists','work',q{length path $1024; path=pathname('work'); rc=filename('e555dir',path); handle=dopen('e555dir'); exists=handle>0; if handle>0 then rc=dclose(handle); rc=filename('e555dir');},q{exists=1 and lengthn(path)>0});
# 556-570: reshape and comparison metadata.
$full->('transpose_two_measures_one_subject','transpose',q{data a; subject=1; measure_a=3; measure_b=8; run; proc transpose data=a out=b; by subject; var measure_a measure_b; run; proc sql; create table @T@ as select count(*) as n,sum(col1) as total from b; quit;},q{n=2 and total=11});
$full->('transpose_prefix_and_delimiter','transpose',q{data a; input visit value; datalines;
1 4
2 9
;
run; proc transpose data=a out=@T@ prefix=visit_; id visit; var value; run;},q{visit_1=4 and visit_2=9});
$full->('transpose_copy_constant_attribute','transpose',q{data a; length group $8; group='case'; v1=6; v2=10; run; proc transpose data=a out=b; copy group; var v1 v2; run; proc sql; create table @T@ as select sum(col1) as total,count(*) as n from b; quit;},q{total=16 and n=2});
$full->('wide_array_to_long_sum','matrix',q{data a; id=1; v1=4; v2=7; v3=10; run; data b; set a; array v[3] v1-v3; do measure=1 to dim(v); value=v[measure]; output; end; keep id measure value; run; proc sql; create table @T@ as select count(*) as n,sum(value*measure) as total from b; quit;},q{n=3 and total=48});
$full->('compare_identical_numeric_rows','compare',q{data a; id=1; value=10; run; data b; set a; run; proc compare base=a compare=b noprint; id id; var value; run; %let e560cc=&sysinfo; data @T@; status=&e560cc; run;},q{status=0});
$full->('compare_numeric_difference_flag','compare',q{data a; id=1; value=10; run; data b; id=1; value=12; run; proc compare base=a compare=b noprint; id id; var value; run; %let e561cc=&sysinfo; data @T@; status=&e561cc; changed=band(status,4096)>0; run;},q{changed=1});
$full->('compare_absolute_tolerance','compare',q{data a; value=10; run; data b; value=10.0001; run; proc compare base=a compare=b noprint method=absolute criterion=.001; var value; run; %let e562cc=&sysinfo; data @T@; status=&e562cc; run;},q{status=0});
$row->('open_dataset_attribute_counts','dict',q{handle=open('sashelp.class','i'); n=attrn(handle,'nobs'); vars=attrn(handle,'nvars'); rc=close(handle);},q{n=19 and vars=5 and rc=0});
$full->('open_custom_dataset_varnum','dict',q{data a; first=1; second=2; run; data @T@; handle=open('a','i'); position=varnum(handle,'second'); rc=close(handle); run;},q{position=2 and rc=0});
$full->('metadata_varname_by_position','point',q{data a; sample=4; score=8; run; data @T@; length name $32; handle=open('a','i'); name=varname(handle,2); rc=close(handle); run;},q{name='score'});
$full->('array_vvaluex_dynamic_column','point',q{data @T@; length column $8 text $20; score=17; format score z4.; column='score'; text=vvaluex(column); run;},q{text='0017'});
$row->('macro_work_path_matches_data_function','work',q{length macro_path actual $1024; macro_path="%sysfunc(pathname(work))"; actual=pathname('work'); equal=macro_path=actual;},q{equal=1});
$full->('retained_gap_cluster_count','retain',q{data a; input position; datalines;
10
15
40
43
80
;
run; data b; set a; retain previous . cluster 0; if missing(previous) or position-previous>10 then cluster+1; previous=position; run; data @T@; set b end=last; if last; run;},q{cluster=3});
$full->('by_first_last_flags_counts','by',q{data a; do grp=1 to 3; do x=1 to grp; output; end; end; run; data b; set a; by grp; start=first.grp; finish=last.grp; run; proc sql; create table @T@ as select sum(start) as starts,sum(finish) as finishes,count(*) as n from b; quit;},q{starts=3 and finishes=3 and n=6});
$row->('scan_numeric_list_mean','min',q{length text $30; text='3,6,9,12'; total=0; n=countw(text,','); do i=1 to n; total+input(scan(text,i,','),best32.); end; average=total/n;},q{average=7.5 and n=4});
# 571-588: real ODS plots, computed source values and output ownership.
$full->('gtl_scatter_overlay_computed','gtl',q{data a; do x=1 to 4; y=2*x+1; output; end; run; proc template; define statgraph e571plot; begingraph; layout overlay; scatterplot x=x y=y; endlayout; endgraph; end; run; proc sgrender data=a template=e571plot; run; proc sql; create table @T@ as select sum(y) as total from a; quit;},q{total=24});
$full->('gtl_series_computed','gtl',q{data a; do x=1 to 4; y=x*x; output; end; run; proc template; define statgraph e572plot; begingraph; layout overlay; seriesplot x=x y=y; endlayout; endgraph; end; run; proc sgrender data=a template=e572plot; run; proc sql; create table @T@ as select sum(y) as total from a; quit;},q{total=30});
$full->('gtl_heatmapparm_four_cells','heat',q{data a; do x=1 to 2; do y=1 to 2; z=x+y; output; end; end; run; proc template; define statgraph e573plot; begingraph; layout overlay; heatmapparm x=x y=y colorresponse=z; endlayout; endgraph; end; run; proc sgrender data=a template=e573plot; run; proc sql; create table @T@ as select sum(z) as total,count(*) as n from a; quit;},q{total=12 and n=4});
$full->('sgplot_heatmapparm_preaggregated','heat',q{data a; do x=1 to 2; do y=1 to 3; value=x*y; output; end; end; run; proc sgplot data=a; heatmapparm x=x y=y colorresponse=value; run; proc sql; create table @T@ as select sum(value) as total from a; quit;},q{total=18});
$full->('sgplot_vbar_mean_response','bar',q{data a; input grp $ y; datalines;
A 2
A 4
B 6
B 10
;
run; proc sgplot data=a; vbar grp / response=y stat=mean datalabel; run; proc sql; create table @T@ as select mean(y) as average from a; quit;},q{average=5.5});
$full->('sgplot_vbar_sum_response','bar',q{data a; input grp $ y; datalines;
A 3
A 7
B 5
;
run; proc sgplot data=a; vbar grp / response=y stat=sum; run; proc sql; create table @T@ as select sum(y) as total from a; quit;},q{total=15});
$full->('sgplot_hbar_grouped_response','bar',q{data a; do grp=1 to 2; do category=1 to 3; value=grp+category; output; end; end; run; proc sgplot data=a; hbar category / response=value group=grp groupdisplay=cluster stat=sum; run; proc sql; create table @T@ as select sum(value) as total from a; quit;},q{total=21});
$full->('sgplot_tmplout_owned_tempfile','tmpl',q{%let e578path=%sysfunc(pathname(work))/e578_template.sas; proc sgplot data=sashelp.class tmplout="&e578path"; scatter x=height y=weight; run; data @T@; rc=filename('e578tmp',symget('e578path')); exists=fexist('e578tmp'); deleted=fdelete('e578tmp'); cleared=filename('e578tmp'); run;},q{exists=1 and deleted=0 and cleared=0});
$full->('gtl_layout_lattice_two_panels','gtl',q{data a; do x=1 to 3; y=x*2; z=x*3; output; end; run; proc template; define statgraph e579plot; begingraph; layout lattice / columns=2; layout overlay; scatterplot x=x y=y; endlayout; layout overlay; seriesplot x=x y=z; endlayout; endlayout; endgraph; end; run; proc sgrender data=a template=e579plot; run; proc sql; create table @T@ as select sum(y+z) as total from a; quit;},q{total=30});
$full->('gtl_bar_chart_summary','render',q{data a; do category=1 to 3; value=category*4; output; end; run; proc template; define statgraph e580plot; begingraph; layout overlay; barchartparm category=category response=value; endlayout; endgraph; end; run; proc sgrender data=a template=e580plot; run; proc sql; create table @T@ as select sum(value) as total from a; quit;},q{total=24});
$full->('sgplot_vbar_weighted_frequency','bar',q{data a; input category $ frequency; datalines;
A 3
B 7
;
run; proc sgplot data=a; vbar category / freq=frequency; run; proc sql; create table @T@ as select sum(frequency) as total from a; quit;},q{total=10});
$full->('sgplot_scatter_style_shapes','gtl',q{data a; do grp=1 to 2; do x=1 to 3; y=x+grp; output; end; end; run; ods graphics / attrpriority=none; proc sgplot data=a; styleattrs datasymbols=(circlefilled squarefilled); scatter x=x y=y / group=grp; run; proc sql; create table @T@ as select sum(y) as total from a; quit;},q{total=21});
$full->('sgplot_series_grouped','gtl',q{data a; do grp=1 to 2; do x=1 to 4; y=x*grp; output; end; end; run; proc sgplot data=a; series x=x y=y / group=grp markers; run; proc sql; create table @T@ as select sum(y) as total from a; quit;},q{total=30});
$full->('sgplot_vbox_two_groups','tmpl',q{data a; do grp=1 to 2; do x=1 to 5; y=x+grp; output; end; end; run; proc sgplot data=a; vbox y / category=grp; run; proc sql; create table @T@ as select min(y) as low,max(y) as high from a; quit;},q{low=2 and high=7});
$full->('sgplot_histogram_small_dataset','render',q{data a; do x=1 to 12; output; end; run; proc sgplot data=a; histogram x / binwidth=3; run; proc sql; create table @T@ as select mean(x) as average from a; quit;},q{average=6.5});
$full->('sgplot_band_intervals','gtl',q{data a; do x=1 to 4; y=x*2; lower=y-1; upper=y+1; output; end; run; proc sgplot data=a; band x=x lower=lower upper=upper; series x=x y=y; run; proc sql; create table @T@ as select sum(upper-lower) as width from a; quit;},q{width=8});
$full->('sgplot_reference_line_computed','gtl',q{data a; do x=1 to 5; y=x*x; output; end; run; proc sgplot data=a; scatter x=x y=y; refline 9 / axis=y; run; proc sql; create table @T@ as select max(y) as high from a; quit;},q{high=25});
$full->('sgplot_discrete_axis_long_labels','bar',q{data a; length label $32; label='first synthetic category'; value=5; output; label='second synthetic category'; value=9; output; run; proc sgplot data=a; vbarparm category=label response=value; xaxis fitpolicy=rotate; run; proc sql; create table @T@ as select sum(value) as total from a; quit;},q{total=14});
# 589-590: intentional SAS failures must retain FAILED status.
$full->('intentional_array_index_out_of_range','array',q{data @T@; array a[2] x1-x2 (1 2); index=3; value=a[index]; run;},undef,fail=>1,diagnostic=>q{Array subscript out of range});
$full->('intentional_sort_missing_by_variable','sort',q{data @T@; do x=3,1,2; output; end; run; proc sort data=@T@; by e590absent x; run;},undef,fail=>1,diagnostic=>q{E590ABSENT.*not found|not found.*E590ABSENT});
die 'Expected 100 new cases' unless @cases==100 && $number==590;
return \@cases;
