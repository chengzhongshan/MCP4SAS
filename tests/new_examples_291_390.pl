use strict; use warnings;
my (@cases,$number); $number=290;
my %src=(defer=>q{D:dosubl vs call execut to run sas macro.sas},dosubl=>q{D:dosubl Demo with _str_ function and return var by macro.sas},
 macro=>q{D:sysevalf demo with macro SizeIt.sas},hash=>q{D:hash4bigdata_demo.sas},multi=>q{E:demo4hash_find_next_with_do_while_loop.sas},tree=>q{E:demo4hash_find_next_with_do_while_loop4tree_branches.sas},
 hold=>q{E:datastep_escape_columns_with_input_infile_and_scan.sas},ats=>q{E:use @ and @@ to split data in the same line to separated rows.sas},
 lines=>q{E:use_double_and_single_at2read_multiple_lines_and_provide_common_variables_to_each_line.sas},files=>q{E:Multiple files with infile statement only functional with dummy.sas},
 csv=>q{E:import_compressed_csv_file_with_quotes.sas},zip=>q{E:ImportFileHeadersFromZIP_works_with_variable_char_length_demo.sas},
 import=>q{D:Proc Import with GuessingRows.sas},dlm=>q{D:very useful Proc Import with different delimiter in dbms_dlm part.sas},export=>q{D:export data with file function along with dlm to separate cols with specific delimiter.sas},
 strip=>q{D:Use Strip and Compbl functions for SAS Infile Blank Space Sparated Files.sas},array=>q{D:Use array, especially temporary array of colnames, to change wide form data into long format data.sas},
 permutation=>q{E:randomply_select_columns_from_large_wide_table_using_temporary_array_with_ranperm.sas},stop=>q{E:data stop array to create variables.sas},geno=>q{E:make_allele_columns_into_single_genotype_column.sas},
 imlcat=>q{E:concatenate_vector_vertically_or_horizontally_in_iml.sas},imlchar=>q{E:convert_string_into_vector_using_cshape_in_proc_iml.sas},imlmeta=>q{E:proc_iml_to_get_sas_dataset_variable_names_using_contents.sas},
 copy=>q{D:Proc dataset change dataset name and copy with select to new lib.sas},ds=>q{D:Delete datasets with Proc datasets.sas},prefix=>q{D:Set multiple datasets with similar names in SAS.sas},
 dups=>q{D:Proc sort to output duplicates in new dataset.sas},merge=>q{D:SAS Merge for update missing values from other dataset very useful.sas},sqlarray=>q{D:Proc SQL Works with Array Function as well as ceil index functions.sas},
 index=>q{D:SAS make Index codes.sas},first=>q{D:SAS Function First.obs and Last.obs in datastep Demo.sas},freq=>q{E:output proc freq summary with out function.sas},
 sign=>q{D:GWAS sign test with proc univariate.sas},fisher=>q{D:ODA_fisher_test_demo_codes.sas},beta=>q{E:generate_random_beta_values.sas},quantile=>q{D:Quantile normalization demo.sas},
 printto=>q{D:Proc Printto demo.sas},printfile=>q{D:Proc Printto output log to sepecific file demo.sas},ods=>q{E:ods select and exclude demo.sas},glm=>q{E:add quit to restore ods output before using ods select none in proc glm.sas},ifn=>q{D:ifn demo for if not condition.sas},fcmp=>q{D:proc fcmp demo with sas macro.sas});
my $full=sub {my($name,$key,$body,$condition,%extra)=@_; my $id=''.++$number; $body=~s/\@T\@/e$id/g; $condition=~s/\@T\@/e$id/g if defined $condition;
 $body.="\ndata _null_; set e$id; if $condition then put 'MCP30_OK_$id'; else put 'ERROR: MCP30_ASSERT_$id'; run;\nproc print data=e$id; run;\n" if defined $condition;
 push @cases,{id=>$id,name=>$name,source_ref=>$src{$key},description=>$condition//$name,sas=>$body,%extra};};
my $row=sub {my($n,$k,$b,$c,%x)=@_; $full->($n,$k,"data \@T\@; $b run;",$c,%x)};
# 291-300: deferred macro contexts and macro arithmetic.
$full->('execute_nrstr_literal_dependency','defer',q{data _null_; call execute('%let e291text=%nrstr(%e291_literal());'); run; data @T@; length value $80; value=symget('e291text'); run;},q{value='%e291_literal()'},forbid=>q{Injected targeted remote macro loader for: e291_literal});
$full->('dosubl_nrstr_literal_dependency','dosubl',q{data @T@; length value $80; rc=dosubl('%let e292text=%nrstr(%e292_literal());'); value=symget('e292text'); run;},q{rc=0 and value='%e292_literal()'},forbid=>q{Injected targeted remote macro loader for: e292_literal});
$full->('execute_data_step_is_deferred','defer',q{%let e293value=before; data @T@; call execute('data _null_; call symputx("e293value","after","G"); run;'); length observed $20; observed=symget('e293value'); run;},q{observed='before' and symget('e293value')='after'});
$full->('dosubl_data_step_is_synchronous','defer',q{%let e294value=before; data @T@; rc=dosubl('data _null_; call symputx("e294value","after","G"); run;'); length observed $20; observed=symget('e294value'); run;},q{rc=0 and observed='after'});
$full->('execute_generated_procedure','defer',q{data a; do value=1 to 4; output; end; run; data _null_; call execute('proc sql; create table e295 as select sum(value) as total from a; quit;'); run;},q{total=10});
$full->('dosubl_concat_split_arguments','dosubl',q{data @T@; length command $100; command=cats('%let e296value=',put(11+12,best12.),';'); rc=dosubl(command); value=input(symget('e296value'),best32.); run;},q{rc=0 and value=23});
$full->('sysevalf_boolean_fraction','macro',q{%let e297value=%sysevalf(0.1+0.2>0.25,boolean); data @T@; value=&e297value; run;},q{value=1});
$full->('sysevalf_integer_ceiling','macro',q{%let e298value=%sysevalf(7/3,ceil); data @T@; value=&e298value; run;},q{value=3});
$full->('sysevalf_integer_floor','macro',q{%let e299value=%sysevalf(-7/3,floor); data @T@; value=&e299value; run;},q{value=-3});
$full->('macro_sysfunc_dosubl_side_effect','dosubl',q{%let e300rc=%sysfunc(dosubl(%str(data e300; value=31; run;)));},q{value=31});
# 301-310: hash key/data, mutation, iterator and multidata contracts.
$row->('hash_check_does_not_load_data','hash',q{key=1; value=10; declare hash h(); rc=h.definekey('key'); rc=h.definedata('value'); rc=h.definedone(); rc=h.add(); value=99; rc=h.check();},q{rc=0 and value=99});
$row->('hash_find_restores_data','hash',q{key=1; value=10; declare hash h(); rc=h.definekey('key'); rc=h.definedata('value'); rc=h.definedone(); rc=h.add(); value=99; rc=h.find();},q{rc=0 and value=10});
$row->('hash_replace_existing_key','hash',q{key=1; value=10; declare hash h(); rc=h.definekey('key'); rc=h.definedata('value'); rc=h.definedone(); rc=h.add(); value=25; rc=h.replace(); value=.; rc=h.find();},q{rc=0 and value=25});
$row->('hash_remove_then_find_missing','hash',q{key=1; value=10; declare hash h(); rc=h.definekey('key'); rc=h.definedata('value'); rc=h.definedone(); rc=h.add(); removed=h.remove(); rc=h.find(); n=h.num_items;},q{removed=0 and rc ne 0 and n=0});
$row->('hash_iterator_ordered_keys','hash',q{key=.; value=.; declare hash h(ordered:'a'); declare hiter it('h'); rc=h.definekey('key'); rc=h.definedata('key','value'); rc=h.definedone(); do key=3,1,2; value=key*10; rc=h.add(); end; total=0; rc=it.first(); smallest=key; do while(rc=0); total+value; rc=it.next(); end;},q{smallest=1 and total=60});
$row->('hash_multidata_find_next','multi',q{key=1; value=.; declare hash h(multidata:'y'); rc=h.definekey('key'); rc=h.definedata('value'); rc=h.definedone(); do value=4,7; rc=h.add(); end; total=0; rc=h.find(); do while(rc=0); total+value; rc=h.find_next(); end;},q{total=11});
$row->('hash_clear_all_entries','hash',q{key=.; declare hash h(); rc=h.definekey('key'); rc=h.definedata('key'); rc=h.definedone(); do key=1 to 3; rc=h.add(); end; cleared=h.clear(); n=h.num_items;},q{cleared=0 and n=0});
$row->('hash_suminc_counter','hash',q{key=1; count=1; total=.; declare hash h(suminc:'count'); rc=h.definekey('key'); rc=h.definedone(); rc=h.add(); rc=h.find(); rc=h.find(); rc=h.sum(sum:total);},q{total=3});
$row->('hash_duplicate_add_rejected','multi',q{key=1; value=4; declare hash h(); rc=h.definekey('key'); rc=h.definedata('value'); rc=h.definedone(); rc=h.add(); value=8; duplicate=h.add(); rc=h.find();},q{duplicate ne 0 and value=4});
$row->('hash_tree_parent_chain','tree',q{child=.; parent=.; declare hash h(); rc=h.definekey('child'); rc=h.definedata('parent'); rc=h.definedone(); child=3; parent=2; rc=h.add(); child=2; parent=1; rc=h.add(); child=1; parent=0; rc=h.add(); child=3; depth=0; rc=h.find(); do while(rc=0 and parent>0); depth+1; child=parent; rc=h.find(); end; root=child;},q{depth=2 and root=1});
# 311-325: held records, physical files, import and ZIP/GZIP.
$full->('input_at_hold_then_release','hold',q{data calc; infile datalines; input @; length first $8; first=scan(_infile_,1); input word $ value; datalines;
alpha 12
beta 7
;
run; proc sql; create table @T@ as select sum(value) as total,count(*) as n,sum(first=word) as matches from calc; quit;},q{total=19 and n=2 and matches=2});
$full->('input_double_at_multiple_records','ats',q{data calc; input word $ value @@; datalines;
a 1 b 2 c 3
;
run; proc sql; create table @T@ as select count(*) as n,sum(value) as total from calc; quit;},q{n=3 and total=6},quality=>1,diagnostic=>q{SAS went to a new line});
$full->('input_group_label_shared_fields','ats',q{data calc; input grp $ @; do idx=1 to 2; input value @; output; end; input; datalines;
A 10 20
B 30 40
;
run; proc sql; create table @T@ as select count(*) as n,sum(value) as total,count(distinct grp) as groups from calc; quit;},q{n=4 and total=100 and groups=2});
$full->('input_column_pointer_fixed_width','lines',q{data calc; input @1 key $2. @4 value 3.; datalines;
AA 123
BB 045
;
run; proc sql; create table @T@ as select sum(value) as total from calc; quit;},q{total=168});
$full->('input_line_pointer_two_lines','lines',q{data calc; input #1 key $ #2 value; datalines;
A
12
B
34
;
run; proc sql; create table @T@ as select sum(value) as total,count(*) as n from calc; quit;},q{total=46 and n=2});
$full->('filevar_two_owned_files','files',q{filename f1 "%sysfunc(pathname(work))/e316a.txt"; filename f2 "%sysfunc(pathname(work))/e316b.txt"; data _null_; file f1; put '2'; file f2; put '5'; run; data filelist; length path $1024; path=pathname('f1'); output; path=pathname('f2'); output; run; data calc; set filelist; infile dummy filevar=path end=done truncover; do iteration=1 to 10 until(done); input value; output; end; if not done then put 'ERROR: bounded FILEVAR read did not terminate'; run; proc sql; create table @T@ as select count(*) as n,sum(value) as total from calc; quit; data _null_; a=fdelete('f1'); b=fdelete('f2'); run; filename f1 clear; filename f2 clear;},q{n=2 and total=7});
$full->('csv_dsd_embedded_comma','csv',q{data @T@; length word $30; infile datalines dlm=',' dsd truncover; input word :$30. value; datalines;
"alpha,beta",7
;
run;},q{word='alpha,beta' and value=7});
$full->('csv_dsd_doubled_quote','csv',q{data @T@; length word $30; infile datalines dlm=',' dsd truncover; input word :$30. value; datalines;
"author""s",9
;
run;},q{word='author"s' and value=9});
$full->('input_question_modifier_invalid_missing','hold',q{data @T@; input value ?? best32.; datalines;
notnumeric
;
run;},q{missing(value) and _error_=0});
$full->('input_hexadecimal_informat','hold',q{data @T@; input value hex4.; datalines;
00FF
;
run;},q{value=255});
$full->('import_csv_guessingrows_types','import',q{filename e321file temp; data _null_; file e321file; put 'key,value'; put 'alpha,10'; put 'beta,20'; run; proc import datafile=e321file dbms=csv out=calc replace; getnames=yes; guessingrows=20; run; proc sql; create table @T@ as select sum(value) as total,count(*) as n from calc; quit; filename e321file clear;},q{total=30 and n=2});
$full->('import_pipe_delimited_no_headers','dlm',q{filename e322file temp; data _null_; file e322file; put 'a|4'; put 'b|6'; run; proc import datafile=e322file dbms=dlm out=calc replace; delimiter='|'; getnames=no; guessingrows=20; run; proc sql; create table @T@ as select sum(var2) as total from calc; quit; filename e322file clear;},q{total=10});
$full->('file_dsd_export_roundtrip','export',q{filename e323file temp; data _null_; file e323file dsd dlm=','; length word $30; word='a,b'; value=7; put word value; run; data @T@; length word $30; infile e323file dsd dlm=',' truncover; input word :$30. value; run; filename e323file clear;},q{word='a,b' and value=7});
$full->('zip_member_owned_roundtrip','zip',q{filename e324zip zip "%sysfunc(pathname(work))/e324.zip" member='records.csv'; data _null_; file e324zip; put '7,11'; run; data @T@; infile e324zip dlm=','; input x y; run; filename e324zip clear; data _null_; rc=filename('e324del',cats(pathname('work'),'/e324.zip')); rc=fdelete('e324del'); rc=filename('e324del'); run;},q{x=7 and y=11});
$full->('gzip_owned_roundtrip','zip',q{filename e325zip zip "%sysfunc(pathname(work))/e325.gz" gzip; data _null_; file e325zip; put '8 12'; run; data @T@; infile e325zip; input x y; run; filename e325zip clear; data _null_; rc=filename('e325del',cats(pathname('work'),'/e325.gz')); rc=fdelete('e325del'); rc=filename('e325del'); run;},q{x=8 and y=12});
# 326-335: arrays, reshape, permutation and genotype normalization.
$full->('array_wide_to_long_named_columns','array',q{data a; id=1; x=4; y=6; run; data calc; set a; array values[2] x y; array names[2] $8 _temporary_ ('first','second'); do i=1 to dim(values); value=values[i]; name=names[i]; output; end; keep id value name; run; proc sql; create table @T@ as select count(*) as n,sum(value) as total,count(distinct name) as names from calc; quit;},q{n=2 and total=10 and names=2});
$row->('array_lower_bound_nonzero','array',q{array a[0:2] (2 4 8); value=a[0]+a[2]; lower=lbound(a); upper=hbound(a);},q{value=10 and lower=0 and upper=2});
$row->('array_two_dimensional_row_major','array',q{array a[2,2] (1 2 3 4); value=a[2,1]; total=sum(of a[*]);},q{value=3 and total=10});
$row->('array_call_sortn_order','permutation',q{array a[4] (8 2 5 1); call sortn(of a[*]); low=a[1]; high=a[4];},q{low=1 and high=8});
$row->('array_call_sortc_order','array',q{array a[3] $8 ('zeta','beta','alpha'); call sortc(of a[*]); length first last $8; first=a[1]; last=a[3];},q{first='alpha' and last='zeta'});
$row->('ranperm_preserves_multiset','permutation',q{array a[5] (1 2 3 4 5); seed=54321; call ranperm(seed,of a[*]); total=sum(of a[*]); low=min(of a[*]); high=max(of a[*]);},q{total=15 and low=1 and high=5});
$row->('array_implicit_element_names','stop',q{array z[3]; do i=1 to dim(z); z[i]=i*i; end; total=sum(of z[*]);},q{total=14});
$full->('if_zero_set_nobs_without_read','stop',q{data a; do value=1 to 7; output; end; run; data @T@; if 0 then set a nobs=n; count=n; output; stop; run;},q{count=7});
$row->('genotype_sort_allele_pair','geno',q{a=1; b=0; length value $2; value=cats(put(min(a,b),1.),put(max(a,b),1.));},q{value='01'});
$row->('genotype_missing_guard','geno',q{a=.; b=1; length value $2; if nmiss(a,b) then value='NA'; else value=cats(a,b);},q{value='NA'});
# 336-345: small deterministic IML matrix operations.
for my $s (
 ['iml_horizontal_concatenation','imlcat',q{a={1 2}; b={3 4}; c=a||b; n=ncol(c); total=sum(c);},q{n=4 and total=10},'n total'],
 ['iml_vertical_concatenation','imlcat',q{a={1 2}; b={3 4}; c=a//b; n=nrow(c); total=sum(c);},q{n=2 and total=10},'n total'],
 ['iml_shape_row_major','imlcat',q{a=shape(1:6,2,3); value=a[2,1];},q{value=4},'value'],
 ['iml_cshape_character_vector','imlchar',q{a=cshape('ABCD',1,4,1); value=ncol(a);},q{value=4},'value'],
 ['iml_loc_positive_indices','imlcat',q{a={-2 0 3 4}; idx=loc(a>0); n=ncol(idx); total=sum(idx);},q{n=2 and total=7},'n total'],
 ['iml_matrix_product','imlcat',q{a={1 2,3 4}; b=a*a; value=b[2,2];},q{value=22},'value'],
 ['iml_inverse_identity','imlcat',q{a={2 1,1 2}; b=a*inv(a); err=max(abs(b-I(2)));},q{err<1e-10},'err'],
 ['iml_determinant_trace','imlcat',q{a={2 1,1 2}; determinant=det(a); diagonal=trace(a);},q{abs(determinant-3)<1e-10 and diagonal=4},'determinant diagonal'],
 ['iml_current_dataset_contents','imlmeta',q{x={1 2}; create e344meta from x[colname={'alpha' 'beta'}]; append from x; vars=contents(); n=nrow(vars)*ncol(vars); close e344meta;},q{n=2},'n'],
 ['iml_choose_masked_values','imlcat',q{a={1 2 3}; b=choose(a>1,a,0); total=sum(b);},q{total=5},'total']) {
 my($n,$k,$b,$c,$vars)=@$s; $full->($n,$k,"proc iml; $b create \@T\@ var {$vars}; append; close \@T\@; quit;",$c);
}
# 346-355: library datasets, indexes, sort duplicates and updating missing.
$full->('datasets_change_member_name','copy',q{data e346old; value=8; run; proc datasets lib=work nolist; change e346old=e346new; quit; data @T@; set e346new; oldexists=exist('e346old'); run;},q{value=8 and oldexists=0});
$full->('datasets_modify_variable_rename','ds',q{data a; original=9; run; proc datasets lib=work nolist; modify a; rename original=renamed; quit; data @T@; set a; run;},q{renamed=9});
$full->('datasets_delete_selected_only','ds',q{data e348drop; x=1; run; data e348keep; x=2; run; proc datasets lib=work nolist; delete e348drop; quit; data @T@; removed=not exist('e348drop'); retained=exist('e348keep'); run;},q{removed=1 and retained=1});
$full->('set_prefix_list_concatenation','prefix',q{data e349parta; value=4; run; data e349partb; value=7; run; data calc; set e349part:; run; proc sql; create table @T@ as select count(*) as n,sum(value) as total from calc; quit;},q{n=2 and total=11});
$full->('sort_dupout_counts_removed','dups',q{data a; do id=1,1,2,3,3; output; end; run; proc sort data=a out=unique nodupkey dupout=duplicates; by id; run; proc sql; create table @T@ as select a.kept,b.removed from (select count(*) as kept from unique) a,(select count(*) as removed from duplicates) b; quit;},q{kept=3 and removed=2});
$full->('update_statement_missing_preserved','merge',q{data master; id=1; x=10; y=20; run; data changes; id=1; x=.; y=30; run; data @T@; update master changes; by id; run;},q{x=10 and y=30});
$full->('update_updatemode_nomissingcheck','merge',q{data master; id=1; x=10; run; data changes; id=1; x=.; run; data @T@; update master changes updatemode=nomissingcheck; by id; run;},q{missing(x)});
$full->('sql_ceil_bucket_assignment','sqlarray',q{data a; do id=1 to 5; output; end; run; proc sql; create table @T@ as select sum(ceil(id/2)) as total from a; quit;},q{total=9});
$full->('dataset_simple_index_lookup','index',q{data a(index=(id)); do id=1 to 10; value=id*3; output; end; run; data @T@; set a; where id=7; run;},q{value=21});
$full->('by_notsorted_contiguous_groups','first',q{data a; do grp=2,2,1,1; output; end; run; data calc; set a; by grp notsorted; if first.grp then output; run; proc sql; create table @T@ as select count(*) as n,sum(grp) as total from calc; quit;},q{n=2 and total=3});
# 356-365: frequency denominators, distribution functions and statistics.
$full->('freq_by_group_percent_denominator','freq',q{data a; grp=1; x=0; output; x=1; output; grp=2; x=1; output; run; proc freq data=a noprint; by grp; tables x/out=counts; run; proc sql; create table @T@ as select max(percent) as high,min(percent) as low from counts; quit;},q{high=100 and low=50});
$full->('freq_missing_category_included','freq',q{data a; do x=.,1,1; output; end; run; proc freq data=a noprint; tables x/missing out=counts; run; proc sql; create table @T@ as select sum(count) as n,count(*) as categories from counts; quit;},q{n=3 and categories=2});
$full->('freq_weighted_counts','fisher',q{data a; x=1; weight=3; output; x=2; weight=7; output; run; proc freq data=a noprint; tables x/out=counts; weight weight; run; proc sql; create table @T@ as select sum(count) as n,max(percent) as high from counts; quit;},q{n=10 and high=70});
$full->('fisher_exact_ods_rows','fisher',q{data a; do grp=1 to 2; do outcome=0 to 1; n=grp+outcome+1; output; end; end; run; ods output FishersExact=fx; proc freq data=a; tables grp*outcome/fisher; weight n; run; ods output close; proc sql; create table @T@ as select count(*) as n from fx; quit;},q{n>0});
$full->('sign_test_location_capture','sign',q{data a; do x=-2,-1,1,2,3; output; end; run; ods output TestsForLocation=loc; proc univariate data=a; var x; run; ods output close; proc sql; create table @T@ as select count(*) as n from loc; quit;},q{n=3});
$row->('beta_uniform_cdf','beta',q{value=cdf('beta',0.3,1,1);},q{abs(value-.3)<1e-10});
$row->('beta_symmetric_median','beta',q{value=quantile('beta',0.5,2,2);},q{abs(value-.5)<1e-10});
$row->('beta_moments_parameter_recovery','beta',q{mu=.5; variance=.05; alpha=mu*(mu*(1-mu)/variance-1); beta=(1-mu)*(mu*(1-mu)/variance-1);},q{alpha=2 and beta=2});
$full->('quantile_norm_sorted_column_means','quantile',q{data a; do rank=1 to 3; x=rank; y=rank*2; normalized=mean(x,y); output; end; run; proc sql; create table @T@ as select sum(normalized) as total,min(normalized) as low,max(normalized) as high from a; quit;},q{total=9 and low=1.5 and high=4.5});
$row->('seeded_beta_draw_valid_range','beta',q{call streaminit(24680); low=1; high=0; do i=1 to 100; value=rand('beta',2,5); low=min(low,value); high=max(high,value); end;},q{low>0 and high<1});
# 366-370: ODS and redirected logs restored before assertions.
$full->('printto_log_restore_success','printto',q{filename e366log temp; proc printto log=e366log new; run; data a; value=12; run; proc printto; run; data @T@; set a; run; filename e366log clear;},q{value=12});
$full->('printto_print_owned_listing','printfile',q{filename e367lst temp; proc printto print=e367lst new; run; data @T@; value=5; run; proc print data=@T@; run; proc printto; run; filename e367lst clear;},q{value=5});
$full->('ods_exclude_none_restores_output','ods',q{ods exclude all; data @T@; value=6; run; proc print data=@T@; run; ods exclude none;},q{value=6});
$full->('glm_quit_before_ods_recovery','glm',q{data a; do x=1 to 5; y=x*2; output; end; run; ods select none; ods output ParameterEstimates=pe; proc glm data=a; model y=x/solution; run; quit; ods output close; ods select all; proc sql; create table @T@ as select count(*) as n from pe; quit;},q{n=2});
$full->('fcmp_macro_function_bridge','fcmp',q{%macro e370subtract; %let p=%sysevalf(&a-&b); %mend; proc fcmp outlib=work.e370funcs.math; function e370subtract_fn(a,b); rc=run_macro('e370subtract',a,b,p); if rc=0 then return(p); return(.); endsub; quit; options cmplib=work.e370funcs; data @T@; value=e370subtract_fn(9,4); run; options cmplib=();},q{value=5});
# 371-388: distinct scalar/character contracts from the same source motifs.
$row->('ifn_missing_fourth_argument','ifn',q{value=ifn(.,7,9,11);},q{value=11});
$row->('ifn_uninitialized_input_advisory','ifn',q{value=ifn(missing(uninitialized),11,9);},q{value=11},quality=>1,diagnostic=>q{Variable uninitialized is uninitialized});
$row->('compbl_internal_space_normalization','strip',q{length value $40; value=strip(compbl('  alpha   beta  '));},q{value='alpha beta'});
$row->('translate_tab_to_space','strip',q{length value $40; value=translate('a'||'09'x||'b',' ','09'x);},q{value='a b'});
$row->('compress_keep_alphabetic','strip',q{length value $20; value=compress('a1b2-c3',,'ka');},q{value='abc'});
$row->('scan_quoted_delimiter_modifier','csv',q{length value $40; value=scan('"a,b",c',1,',','q');},q{value='"a,b"'});
$row->('scan_empty_tokens_m_modifier','csv',q{length value $8; value=scan('a,,c',2,',','m'); n=countw('a,,c',',','m');},q{missing(value) and n=3});
$row->('findw_whole_word_boundary','strip',q{a=findw('alpha alphabet beta','alpha'); b=findw('alphabet beta','alpha');},q{a=1 and b=0});
$row->('substrn_out_of_range_nonfatal','strip',q{length value $10; value=substrn('abc',10,2);},q{missing(value)});
$row->('repeat_count_is_extra_repetitions','strip',q{length value $10; value=repeat('ab',2);},q{value='ababab'});
$row->('transtrn_remove_token','strip',q{length value $20; value=transtrn('a--b--c','--',trimn(''));},q{value='abc'});
$row->('countc_character_set','strip',q{value=countc('a,b;c,d',',;');},q{value=3});
$row->('sum_statement_missing_ignored','stop',q{total=0; do value=1,.,3; total+value; end;},q{total=4});
$row->('whichn_first_matching_position','array',q{value=whichn(7,2,7,7,9);},q{value=2});
$row->('largest_order_statistic','quantile',q{value=largest(2,1,7,4,9);},q{value=7});
$row->('smallest_order_statistic','quantile',q{value=smallest(2,1,7,4,9);},q{value=4});
$row->('geomean_positive_values','quantile',q{value=geomean(2,8);},q{abs(value-4)<1e-10});
$row->('harmonic_mean_positive_values','quantile',q{value=harmean(2,6);},q{abs(value-3)<1e-10});
# 389-390: real errors, including a redirected SAS ERROR.
$full->('printto_hidden_error_status','printto',q{filename e389log temp; proc printto log=e389log new; run; data bad; set work.e389_missing; run; proc printto; run;},undef,fail=>1,diagnostic=>q{(?:E389_MISSING|SYSCC)});
$full->('hash_undefined_key_failure','hash',q{data bad; value=1; declare hash h(); rc=h.definekey('missing_key'); rc=h.definedata('value'); rc=h.definedone(); run;},undef,fail=>1,diagnostic=>q{(?:missing_key|not.*declared)});
die 'Expected exactly 100 cases ending at 390' unless @cases==100 && $number==390;
return \@cases;
