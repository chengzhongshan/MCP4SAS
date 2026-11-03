/* H2918 dosubl_double_quoted_inc, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/create_macro_vars_in_data_step_and_process_it_with_other_macro.sas:6 */

filename rtemp temp;
data _null_; file rtemp; put 'data h2918a; value=9; run;'; run;
data _null_; rc=dosubl("%inc rtemp;"); run;
filename rtemp clear;
data h2918o; set h2918a; actual=value; run;

data _null_; if 0 then set h2918o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2918 rows=' rows;
else do; set h2918o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND6_PASS=H2918';
else put 'ERROR: ROUND6_FAIL=H2918 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2918:; quit;
