/* H2915 dosubl_double_quoted_inc, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/create_macro_vars_in_data_step_and_process_it_with_other_macro.sas:6 */

filename rtemp temp;
data _null_; file rtemp; put 'data h2915a; value=6; run;'; run;
data _null_; rc=dosubl("%inc rtemp;"); run;
filename rtemp clear;
data h2915o; set h2915a; actual=value; run;

data _null_; if 0 then set h2915o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2915 rows=' rows;
else do; set h2915o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND6_PASS=H2915';
else put 'ERROR: ROUND6_FAIL=H2915 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2915:; quit;
