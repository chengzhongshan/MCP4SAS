/* H2941 sysfunc_dosubl_program, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/create_macro_vars_in_data_step_and_process_it_with_other_macro.sas:6 */

%let h2941rc=%sysfunc(dosubl(data h2941a; value=2; run;));
data h2941o; set h2941a; actual=value+&h2941rc; run;
%symdel h2941rc;

data _null_; if 0 then set h2941o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2941 rows=' rows;
else do; set h2941o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND6_PASS=H2941';
else put 'ERROR: ROUND6_FAIL=H2941 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2941:; quit;
