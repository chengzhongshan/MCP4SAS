/* H2949 sysfunc_dosubl_program, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/create_macro_vars_in_data_step_and_process_it_with_other_macro.sas:6 */

%let h2949rc=%sysfunc(dosubl(data h2949a; value=10; run;));
data h2949o; set h2949a; actual=value+&h2949rc; run;
%symdel h2949rc;

data _null_; if 0 then set h2949o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2949 rows=' rows;
else do; set h2949o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND6_PASS=H2949';
else put 'ERROR: ROUND6_FAIL=H2949 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2949:; quit;
