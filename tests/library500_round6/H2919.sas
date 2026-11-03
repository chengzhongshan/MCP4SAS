/* H2919 dosubl_double_quoted_inc, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/create_macro_vars_in_data_step_and_process_it_with_other_macro.sas:6 */

filename rtemp temp;
data _null_; file rtemp; put 'data h2919a; value=10; run;'; run;
data _null_; rc=dosubl("%inc rtemp;"); run;
filename rtemp clear;
data h2919o; set h2919a; actual=value; run;

data _null_; if 0 then set h2919o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2919 rows=' rows;
else do; set h2919o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND6_PASS=H2919';
else put 'ERROR: ROUND6_FAIL=H2919 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2919:; quit;
