/* H2911 dosubl_double_quoted_inc, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/create_macro_vars_in_data_step_and_process_it_with_other_macro.sas:6 */

filename rtemp temp;
data _null_; file rtemp; put 'data h2911a; value=2; run;'; run;
data _null_; rc=dosubl("%inc rtemp;"); run;
filename rtemp clear;
data h2911o; set h2911a; actual=value; run;

data _null_; if 0 then set h2911o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2911 rows=' rows;
else do; set h2911o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND6_PASS=H2911';
else put 'ERROR: ROUND6_FAIL=H2911 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2911:; quit;
