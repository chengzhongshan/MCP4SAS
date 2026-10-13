use strict;
use warnings;
my @batch;
my $add=sub {
    my ($id,$name,$description,$sas,%extra)=@_;
    push @batch,{id=>$id,name=>$name,description=>$description,sas=>$sas,%extra};
};
$add->('61','quoted_comment_delimiter','A comment opener inside a quoted value must not consume a later real comment.',<<'SAS');
%macro e61quoted;
data e61; length token $20; token='/*'; run;
/* An actual source comment after the quoted token. */
%mend;
%e61quoted;
data _null_; set e61; if token='/*' then put 'MCP30_OK_61'; else put 'ERROR: MCP30_ASSERT_61'; run;
proc print data=e61; run;
SAS
$add->('62','statement_comment_after_semicolon','An inline statement comment can contain an apostrophe.',<<'SAS');
data e62; * author's explanatory note; value=62; run;
data _null_; set e62; if value=62 then put 'MCP30_OK_62'; else put 'ERROR: MCP30_ASSERT_62'; run;
proc print data=e62; run;
SAS
$add->('63','commented_put_example','A nonexecuted PUT example inside a block comment is not a compile blocker.',<<'SAS');
/* Documentation example, not executed:
%put training; explanatory text;
*/
data e63; value=63; run;
data _null_; set e63; if value=63 then put 'MCP30_OK_63'; else put 'ERROR: MCP30_ASSERT_63'; run;
proc print data=e63; run;
SAS
$add->('64','sql_having_group_filter','HAVING retains only the group with aggregate total 15.',<<'SAS');
data e64; input group value; datalines;
1 2
1 3
2 7
2 8
;
proc sql; create table e64selected as select group,sum(value) as total from e64 group by group having calculated total>10; quit;
data _null_; set e64selected; if group=2 and total=15 then put 'MCP30_OK_64'; else put 'ERROR: MCP30_ASSERT_64'; run;
proc print data=e64selected; run;
SAS
$add->('65','correlated_exists_filter','EXISTS filters two keys without multiplying rows.',<<'SAS');
data e65a; do id=1 to 4; output; end; run;
data e65b; id=2; output; output; id=4; output; run;
proc sql; create table e65selected as select id from e65a a where exists (select * from e65b b where a.id=b.id);
select count(*),sum(id) into :e65n,:e65sum from e65selected; quit;
data _null_; if &e65n=2 and &e65sum=6 then put 'MCP30_OK_65'; else put 'ERROR: MCP30_ASSERT_65'; run;
SAS
$add->('66','full_outer_join_keys','Full join retains unmatched keys from both sides.',<<'SAS');
data e66a; do id=1 to 2; a=id*10; output; end; run;
data e66b; do id=2 to 3; b=id*20; output; end; run;
proc sql; create table e66joined as select coalesce(a.id,b.id) as id,a.a,b.b from e66a a full join e66b b on a.id=b.id;
select count(*),sum(id) into :e66n,:e66sum from e66joined; quit;
data _null_; if &e66n=3 and &e66sum=6 then put 'MCP30_OK_66'; else put 'ERROR: MCP30_ASSERT_66'; run;
SAS
$add->('67','cross_join_product','Two-by-three Cartesian product contains six rows.',<<'SAS');
data e67a; do a=1 to 2; output; end; run;
data e67b; do b=1 to 3; output; end; run;
proc sql; create table e67cross as select a,b from e67a cross join e67b;
select count(*) into :e67n from e67cross; quit;
data _null_; if &e67n=6 then put 'MCP30_OK_67'; else put 'ERROR: MCP30_ASSERT_67'; run;
SAS
$add->('68','merge_membership_flags','DATA-step MERGE IN flags distinguish left-only, shared and right-only keys.',<<'SAS');
data e68a; do id=1 to 2; output; end; run;
data e68b; do id=2 to 3; output; end; run;
data e68; merge e68a(in=left) e68b(in=right); by id; from_left=left; from_right=right; run;
data _null_; set e68 end=last; retain good 0;
good+(id=1 and from_left and not from_right) or (id=2 and from_left and from_right) or (id=3 and not from_left and from_right);
if last then do; if good=3 then put 'MCP30_OK_68'; else put 'ERROR: MCP30_ASSERT_68'; end; run;
proc print data=e68; run;
SAS
$add->('69','call_execute_generated_step','CALL EXECUTE schedules a generated DATA step.',<<'SAS');
data _null_; call execute('data e69; value=69; run;'); run;
data _null_; set e69; if value=69 then put 'MCP30_OK_69'; else put 'ERROR: MCP30_ASSERT_69'; run;
proc print data=e69; run;
SAS
$add->('70','symputx_numeric_transfer','CALL SYMPUTX transfers a calculated total to a macro variable.',<<'SAS');
data _null_; total=0; do value=1 to 7; total+value; end; call symputx('e70total',total,'G'); run;
data e70; value=&e70total; run;
data _null_; set e70; if value=28 then put 'MCP30_OK_70'; else put 'ERROR: MCP30_ASSERT_70'; run;
proc print data=e70; run;
SAS
$add->('71','sysfunc_math_expression','SYSFUNC evaluates a SAS numeric function during macro expansion.',<<'SAS');
%let e71root=%sysfunc(sqrt(81));
data e71; value=&e71root; run;
data _null_; set e71; if value=9 then put 'MCP30_OK_71'; else put 'ERROR: MCP30_ASSERT_71'; run;
proc print data=e71; run;
SAS
$add->('72','qscan_quoted_separator','QSCAN preserves a comma inside a quoted list item.',<<'SAS');
%let e72list=%str(alpha,"beta,gamma",delta);
%let e72item=%qscan(%superq(e72list),2,%str(,),q);
data e72; length token $40; token=symget('e72item'); run;
data _null_; set e72; if token='"beta,gamma"' then put 'MCP30_OK_72'; else put 'ERROR: MCP30_ASSERT_72'; run;
proc print data=e72; run;
SAS
$add->('73','iso_datetime_interval','ISO datetime informat yields a 90-second interval.',<<'SAS');
data e73; start=input('2024-06-01T12:00:00',e8601dt19.); finish=input('2024-06-01T12:01:30',e8601dt19.); format start finish e8601dt19.; run;
data _null_; set e73; if finish-start=90 then put 'MCP30_OK_73'; else put 'ERROR: MCP30_ASSERT_73'; run;
proc print data=e73; run;
SAS
$add->('74','multibyte_character_slice','KSUBSTR extracts a complete UTF-8 accented character.',<<'SAS');
data e74; length text $20 character $8; text='caf'||'C3A9'x; character=ksubstr(text,4,1); run;
data _null_; set e74; if character='C3A9'x then put 'MCP30_OK_74'; else put 'ERROR: MCP30_ASSERT_74'; run;
proc print data=e74; run;
SAS
$add->('75','md5_known_vector','MD5 returns the known digest for abc.',<<'SAS');
data e75; length digest $32; digest=put(md5('abc'),$hex32.); run;
data _null_; set e75; if digest='900150983CD24FB0D6963F7D28E17F72' then put 'MCP30_OK_75'; else put 'ERROR: MCP30_ASSERT_75'; run;
proc print data=e75; run;
SAS
$add->('76','compressed_dataset_rename','Compressed dataset remains readable after DATASETS rename.',<<'SAS');
data e76original(compress=yes); length text $200; do id=1 to 4; text=repeat('x',100); output; end; run;
proc datasets library=work nolist; change e76original=e76renamed; quit;
proc sql noprint; select count(*) into :e76n from e76renamed; quit;
data _null_; if &e76n=4 then put 'MCP30_OK_76'; else put 'ERROR: MCP30_ASSERT_76'; run;
proc print data=e76renamed; run;
SAS
$add->('77','sql_view_live_data','SQL view observes a later update to its underlying table.',<<'SAS');
data e77base; value=1; run;
proc sql; create view e77view as select value from e77base; update e77base set value=77; quit;
data _null_; set e77view; if value=77 then put 'MCP30_OK_77'; else put 'ERROR: MCP30_ASSERT_77'; run;
proc print data=e77view; run;
SAS
$add->('78','standardized_mean_variance','PROC STANDARD produces mean zero and sample standard deviation one.',<<'SAS');
data e78; do value=1 to 5; output; end; run;
proc standard data=e78 mean=0 std=1 out=e78std; var value; run;
proc means data=e78std noprint; var value; output out=e78check mean=mean std=sd; run;
data _null_; set e78check; if abs(mean)<1e-10 and abs(sd-1)<1e-10 then put 'MCP30_OK_78'; else put 'ERROR: MCP30_ASSERT_78'; run;
proc print data=e78std; run;
SAS
$add->('79','geographic_distance_units','GEODIST computes roughly 111 km for one degree on the equator.',<<'SAS');
data e79; km=geodist(0,0,0,1,'K'); run;
data _null_; set e79; if 100<km and km<120 then put 'MCP30_OK_79'; else put 'ERROR: MCP30_ASSERT_79'; run;
proc print data=e79; run;
SAS
$add->('80','survey_weighted_mean','SURVEYMEANS returns weighted mean 170/6.',<<'SAS');
data e80; input value weight; datalines;
10 1
20 1
30 2
40 2
;
ods output Statistics=e80stats;
proc surveymeans data=e80 mean; var value; weight weight; run;
data _null_; set e80stats; if abs(mean-170/6)<1e-8 then put 'MCP30_OK_80'; else put 'ERROR: MCP30_ASSERT_80'; run;
SAS
$add->('81','monthly_date_aggregation','Dates aggregate into January count two and February count one.',<<'SAS');
data e81; input date :date9.; format date date9.; datalines;
01JAN2024
25JAN2024
01FEB2024
;
proc sql; create table e81month as select intnx('month',date,0,'beginning') as month format=date9.,count(*) as n
from e81 group by calculated month; quit;
data _null_; set e81month end=last; retain good 0; good+(month='01JAN2024'd and n=2) or (month='01FEB2024'd and n=1);
if last then do; if good=2 then put 'MCP30_OK_81'; else put 'ERROR: MCP30_ASSERT_81'; end; run;
proc print data=e81month; run;
SAS
$add->('82','datasets_attribute_modify','DATASETS modifies a column label without changing its numeric value.',<<'SAS');
data e82; value=82; run;
proc datasets library=work nolist; modify e82; label value='Adjusted measurement'; format value 8.2; quit;
data _null_; set e82; if value=82 and vlabel(value)='Adjusted measurement' then put 'MCP30_OK_82'; else put 'ERROR: MCP30_ASSERT_82'; run;
proc print data=e82; run;
SAS
$add->('83','fopen_fread_fileref','File functions read a generated temporary text file.',<<'SAS');
filename e83file temp;
data _null_; file e83file; put 'generated-record-83'; run;
data e83; length record $80; fid=fopen('e83file'); rc=fread(fid); rc=fget(fid,record,80); rc=fclose(fid); run;
data _null_; set e83; if record='generated-record-83' then put 'MCP30_OK_83'; else put 'ERROR: MCP30_ASSERT_83'; run;
proc print data=e83; run; filename e83file clear;
SAS
$add->('84','additional_ods_html_destination','An explicit second ODS HTML destination creates a nonempty file.',<<'SAS');
data e84; value=84; run;
ods html(id=e84) file="%sysfunc(pathname(work))/e84.html";
proc print data=e84; run;
ods html(id=e84) close;
filename e84html "%sysfunc(pathname(work))/e84.html";
data _null_; fid=fopen('e84html'); if fid>0 then do;
rc=fread(fid); if rc=0 then put 'MCP30_OK_84'; else put 'ERROR: MCP30_ASSERT_84'; rc=fclose(fid); end;
else put 'ERROR: MCP30_ASSERT_84'; run; filename e84html clear;
SAS
$add->('85','sql_update_delete','UPDATE and DELETE leave two rows with total 103.',<<'SAS');
data e85; do id=1 to 3; value=id; output; end; run;
proc sql; update e85 set value=100 where id=2; delete from e85 where id=1;
select count(*),sum(value) into :e85n,:e85sum from e85; quit;
data _null_; if &e85n=2 and &e85sum=103 then put 'MCP30_OK_85'; else put 'ERROR: MCP30_ASSERT_85'; run;
proc print data=e85; run;
SAS
$add->('86','set_character_length_warning','SET reports differing character lengths and exposes truncation.',<<'SAS',diagnostic=>'WARNING',warning=>1);
data e86a; length text $3; id=1; text='one'; run;
data e86b; length text $6; id=2; text='planet'; run;
data e86; set e86a e86b; run;
data _null_; set e86; if id=2 then do;
if text='pla' then put 'MCP30_OK_86'; else put 'ERROR: MCP30_ASSERT_86'; end; run;
proc print data=e86; run;
SAS
$add->('87','unknown_numeric_function','An undefined DATA-step function is a genuine compile failure.',<<'SAS',fail=>1,diagnostic=>'unknown|not found');
data e87; value=mcp90_never_defined(1); run;
SAS
$add->('88','sql_join_type_error','SQL join on incompatible key types must fail.',<<'SAS',fail=>1,diagnostic=>'different data types');
data e88a; id=1; run;
data e88b; length id $4; id='one'; run;
proc sql; select a.id from e88a a inner join e88b b on a.id=b.id; quit;
SAS
$add->('89','unknown_procedure','A nonexistent SAS procedure must fail.',<<'SAS',fail=>1,diagnostic=>'Procedure.*not found');
proc mcp90_not_a_proc; run;
SAS
$add->('90','numeric_domain_diagnostics','Invalid LOG and SQRT arguments produce missing values and quality notes.',<<'SAS',diagnostic=>'Invalid argument',quality=>1);
data e90; logarithm=log(-1); root=sqrt(-1); run;
data _null_; set e90; if missing(logarithm) and missing(root) then put 'MCP30_OK_90'; else put 'ERROR: MCP30_ASSERT_90'; run;
proc print data=e90; run;
SAS
return \@batch;
