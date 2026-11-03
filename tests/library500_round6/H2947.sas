/* H2947 sysfunc_dosubl_program, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/create_macro_vars_in_data_step_and_process_it_with_other_macro.sas:6 */

%let h2947rc=%sysfunc(dosubl(data h2947a; value=8; run;));
data h2947o; set h2947a; actual=value+&h2947rc; run;
%symdel h2947rc;

data _null_; if 0 then set h2947o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2947 rows=' rows;
else do; set h2947o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND6_PASS=H2947';
else put 'ERROR: ROUND6_FAIL=H2947 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2947:; quit;
