/* H2917 dosubl_double_quoted_inc, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/create_macro_vars_in_data_step_and_process_it_with_other_macro.sas:6 */

filename rtemp temp;
data _null_; file rtemp; put 'data h2917a; value=8; run;'; run;
data _null_; rc=dosubl("%inc rtemp;"); run;
filename rtemp clear;
data h2917o; set h2917a; actual=value; run;

data _null_; if 0 then set h2917o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2917 rows=' rows;
else do; set h2917o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND6_PASS=H2917';
else put 'ERROR: ROUND6_FAIL=H2917 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2917:; quit;
