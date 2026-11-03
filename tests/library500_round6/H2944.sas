/* H2944 sysfunc_dosubl_program, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/create_macro_vars_in_data_step_and_process_it_with_other_macro.sas:6 */

%let h2944rc=%sysfunc(dosubl(data h2944a; value=5; run;));
data h2944o; set h2944a; actual=value+&h2944rc; run;
%symdel h2944rc;

data _null_; if 0 then set h2944o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2944 rows=' rows;
else do; set h2944o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND6_PASS=H2944';
else put 'ERROR: ROUND6_FAIL=H2944 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2944:; quit;
