/* H2946 sysfunc_dosubl_program, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/create_macro_vars_in_data_step_and_process_it_with_other_macro.sas:6 */

%let h2946rc=%sysfunc(dosubl(data h2946a; value=7; run;));
data h2946o; set h2946a; actual=value+&h2946rc; run;
%symdel h2946rc;

data _null_; if 0 then set h2946o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2946 rows=' rows;
else do; set h2946o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND6_PASS=H2946';
else put 'ERROR: ROUND6_FAIL=H2946 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2946:; quit;
