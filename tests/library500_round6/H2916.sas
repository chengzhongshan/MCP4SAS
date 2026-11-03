/* H2916 dosubl_double_quoted_inc, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/create_macro_vars_in_data_step_and_process_it_with_other_macro.sas:6 */

filename rtemp temp;
data _null_; file rtemp; put 'data h2916a; value=7; run;'; run;
data _null_; rc=dosubl("%inc rtemp;"); run;
filename rtemp clear;
data h2916o; set h2916a; actual=value; run;

data _null_; if 0 then set h2916o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2916 rows=' rows;
else do; set h2916o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND6_PASS=H2916';
else put 'ERROR: ROUND6_FAIL=H2916 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2916:; quit;
