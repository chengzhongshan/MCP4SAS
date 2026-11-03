/* H2914 dosubl_double_quoted_inc, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/create_macro_vars_in_data_step_and_process_it_with_other_macro.sas:6 */

filename rtemp temp;
data _null_; file rtemp; put 'data h2914a; value=5; run;'; run;
data _null_; rc=dosubl("%inc rtemp;"); run;
filename rtemp clear;
data h2914o; set h2914a; actual=value; run;

data _null_; if 0 then set h2914o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2914 rows=' rows;
else do; set h2914o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND6_PASS=H2914';
else put 'ERROR: ROUND6_FAIL=H2914 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2914:; quit;
