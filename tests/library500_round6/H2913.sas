/* H2913 dosubl_double_quoted_inc, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/create_macro_vars_in_data_step_and_process_it_with_other_macro.sas:6 */

filename rtemp temp;
data _null_; file rtemp; put 'data h2913a; value=4; run;'; run;
data _null_; rc=dosubl("%inc rtemp;"); run;
filename rtemp clear;
data h2913o; set h2913a; actual=value; run;

data _null_; if 0 then set h2913o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2913 rows=' rows;
else do; set h2913o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND6_PASS=H2913';
else put 'ERROR: ROUND6_FAIL=H2913 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2913:; quit;
