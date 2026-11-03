/* H2943 sysfunc_dosubl_program, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/create_macro_vars_in_data_step_and_process_it_with_other_macro.sas:6 */

%let h2943rc=%sysfunc(dosubl(data h2943a; value=4; run;));
data h2943o; set h2943a; actual=value+&h2943rc; run;
%symdel h2943rc;

data _null_; if 0 then set h2943o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2943 rows=' rows;
else do; set h2943o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND6_PASS=H2943';
else put 'ERROR: ROUND6_FAIL=H2943 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2943:; quit;
