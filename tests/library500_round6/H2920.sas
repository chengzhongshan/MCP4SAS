/* H2920 dosubl_double_quoted_inc, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/create_macro_vars_in_data_step_and_process_it_with_other_macro.sas:6 */

filename rtemp temp;
data _null_; file rtemp; put 'data h2920a; value=11; run;'; run;
data _null_; rc=dosubl("%inc rtemp;"); run;
filename rtemp clear;
data h2920o; set h2920a; actual=value; run;

data _null_; if 0 then set h2920o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2920 rows=' rows;
else do; set h2920o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND6_PASS=H2920';
else put 'ERROR: ROUND6_FAIL=H2920 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2920:; quit;
