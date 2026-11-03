/* H2912 dosubl_double_quoted_inc, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/create_macro_vars_in_data_step_and_process_it_with_other_macro.sas:6 */

filename rtemp temp;
data _null_; file rtemp; put 'data h2912a; value=3; run;'; run;
data _null_; rc=dosubl("%inc rtemp;"); run;
filename rtemp clear;
data h2912o; set h2912a; actual=value; run;

data _null_; if 0 then set h2912o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2912 rows=' rows;
else do; set h2912o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND6_PASS=H2912';
else put 'ERROR: ROUND6_FAIL=H2912 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2912:; quit;
