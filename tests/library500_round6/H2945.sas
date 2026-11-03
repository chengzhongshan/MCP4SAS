/* H2945 sysfunc_dosubl_program, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/create_macro_vars_in_data_step_and_process_it_with_other_macro.sas:6 */

%let h2945rc=%sysfunc(dosubl(data h2945a; value=6; run;));
data h2945o; set h2945a; actual=value+&h2945rc; run;
%symdel h2945rc;

data _null_; if 0 then set h2945o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2945 rows=' rows;
else do; set h2945o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND6_PASS=H2945';
else put 'ERROR: ROUND6_FAIL=H2945 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2945:; quit;
