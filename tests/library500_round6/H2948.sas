/* H2948 sysfunc_dosubl_program, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/create_macro_vars_in_data_step_and_process_it_with_other_macro.sas:6 */

%let h2948rc=%sysfunc(dosubl(data h2948a; value=9; run;));
data h2948o; set h2948a; actual=value+&h2948rc; run;
%symdel h2948rc;

data _null_; if 0 then set h2948o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2948 rows=' rows;
else do; set h2948o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND6_PASS=H2948';
else put 'ERROR: ROUND6_FAIL=H2948 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2948:; quit;
