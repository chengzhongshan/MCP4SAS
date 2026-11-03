/* H2950 sysfunc_dosubl_program, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/create_macro_vars_in_data_step_and_process_it_with_other_macro.sas:6 */

%let h2950rc=%sysfunc(dosubl(data h2950a; value=11; run;));
data h2950o; set h2950a; actual=value+&h2950rc; run;
%symdel h2950rc;

data _null_; if 0 then set h2950o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2950 rows=' rows;
else do; set h2950o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND6_PASS=H2950';
else put 'ERROR: ROUND6_FAIL=H2950 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2950:; quit;
