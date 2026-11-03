/* H2942 sysfunc_dosubl_program, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/create_macro_vars_in_data_step_and_process_it_with_other_macro.sas:6 */

%let h2942rc=%sysfunc(dosubl(data h2942a; value=3; run;));
data h2942o; set h2942a; actual=value+&h2942rc; run;
%symdel h2942rc;

data _null_; if 0 then set h2942o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2942 rows=' rows;
else do; set h2942o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND6_PASS=H2942';
else put 'ERROR: ROUND6_FAIL=H2942 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2942:; quit;
