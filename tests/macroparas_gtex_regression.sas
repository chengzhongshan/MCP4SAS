/* Owned WORK fixtures only. No GTEx API calls, downloads or research analyses. */
%include "examples/sas_macros/macroparas_portable.sas";
%let _mp_test_root=%sysfunc(pathname(work));
data _null_;
 length directory $4096;
 directory=dcreate('GTEx inspection fixtures',symget('_mp_test_root'));
 call symputx('_mp_test_dir',directory,'G');
run;
filename mptsrc "&_mp_test_dir/GTExOne.sas";
data _null_;
 file mptsrc;
 put '/* %macro GTExOne(bogus=1); must not match a comment. */';
 put '%macro GTExOne(a=1,';
 put '/* An explanatory comment containing ); and nested (parentheses). */';
 put 'where=%str(x in (''A'',''B'')),';
 put 'caption=''space value'', ending=''semi;colon'');';
 put '%put ERROR: DO_NOT_EXECUTE_INSPECTED_MACROS;';
 put '%mend;';
run;
filename mptsrc "&_mp_test_dir/gtEXTwo.SAS";
data _null_;
 file mptsrc;
 put '%macro gtEXTwo;';
 put '%put ERROR: DO_NOT_EXECUTE_INSPECTED_MACROS;';
 put '%mend;';
run;
filename mptsrc "&_mp_test_dir/Other.sas";
data _null_; file mptsrc; put '%macro Other(x=1); %mend;'; run;
filename mptsrc clear;

/* These names were deleted by the former prefix-based cleanup. */
data _mparas1 _macros_ macroparas_user; sentinel=42; run;
%let n=sentinel_n;
%let i=sentinel_i;
%let _mp_before_notes=%sysfunc(getoption(notes));
options nonotes;
%macroparas(macrorgx=GTex,dir=%superq(_mp_test_dir),numlines2print=1,
            output_macropara_dsd=mp_actual,print_outdsd=1);
%let _mp_after_notes=%sysfunc(getoption(notes));
options &_mp_before_notes;

data mp_expected;
 length macro $500;
 macro='GTExOne'; output;
 macro='gtEXTwo'; output;
run;
proc sort data=mp_actual; by macro; run;
proc sort data=mp_expected; by macro; run;
proc compare base=mp_expected compare=mp_actual criterion=0 noprint;
 var macro;
run;
%let _mp_compare=&sysinfo;
proc sql noprint;
 select count(*) into :_mp_signature_ok trimmed from mp_actual
 where macro='GTExOne'
   and index(macro_paras,"caption='space value'")>0
   and index(macro_paras,"ending='semi;colon'")>0
   and index(macro_paras,'bogus')=0
   and index(macro_paras,'x in')>0;
quit;

%macro _mp_assert(condition=,label=);
 %if &condition %then %put MACROPARAS_TEST_PASS=&label;
 %else %put ERROR: MACROPARAS_TEST_FAIL=&label;
%mend;
%_mp_assert(condition=&_mp_compare=0,label=compare_expected_names);
%_mp_assert(condition=&_mp_signature_ok=1,label=complete_signature_beyond_preview);
%_mp_assert(condition=%sysfunc(exist(_mparas1)) and %sysfunc(exist(_macros_)) and %sysfunc(exist(macroparas_user)),label=preserve_caller_tables);
%_mp_assert(condition=%superq(n)=sentinel_n and %superq(i)=sentinel_i,label=preserve_caller_macro_variables);
%_mp_assert(condition=%upcase(&_mp_after_notes)=NONOTES,label=preserve_notes_option);

/* A second call must replace the old result with an empty, valid table. */
%macroparas(macrorgx=DOES_NOT_MATCH_7391,dir=%superq(_mp_test_dir),
            numlines2print=0,output_macropara_dsd=mp_actual);
proc sql noprint;
 select count(*) into :_mp_empty trimmed from mp_actual;
quit;
%_mp_assert(condition=&_mp_empty=0,label=zero_matches_clear_previous_results);

%macroparas(macrorgx=GTex,dir="&_mp_test_dir" "&_mp_test_dir",
            numlines2print=0,output_macropara_dsd=mp_actual);
proc sql noprint;
 select count(*) into :_mp_unique trimmed from mp_actual;
quit;
%_mp_assert(condition=&_mp_unique=2,label=quoted_directory_list_deduplicated);
%let MCP4SAS_MACRO_DIR=%superq(_mp_test_dir);
%macroparas(macrorgx=GTex,numlines2print=0,output_macropara_dsd=mp_actual);
proc sql noprint;
 select count(*) into :_mp_default_count trimmed from mp_actual;
quit;
%_mp_assert(condition=&_mp_default_count=2,label=configured_default_directory);
%symdel MCP4SAS_MACRO_DIR;
/* SASAUTOS often contains fileref names, not literal directory paths. */
%let _mp_saved_autos=%sysfunc(getoption(sasautos));
filename mptauto ("&_mp_test_dir");
options sasautos=(mptauto);
/* Discovery must not execute the inspected source file. */
filename mptsrc "&_mp_test_dir/macroparas.sas";
data _null_; file mptsrc; put '%put ERROR: DO_NOT_EXECUTE_DISCOVERY_FILE;'; run;
filename mptsrc clear;
%macroparas(macrorgx=GTEx,numlines2print=0,output_macropara_dsd=mp_actual);
%let _mp_last=%sysfunc(getoption(_last_));
proc print;run;
proc sql noprint;
 select count(*) into :_mp_auto_count trimmed from mp_actual;
quit;
options sasautos=&_mp_saved_autos;
filename mptauto clear;
%_mp_assert(condition=&_mp_auto_count=2,label=sasautos_fileref_directory);
%_mp_assert(condition=%upcase(&_mp_last)=WORK.MP_ACTUAL,label=implicit_print_result_table);
%put MACROPARAS_REGRESSION_COMPLETE;
