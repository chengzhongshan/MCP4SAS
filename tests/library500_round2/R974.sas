/* R974 dosubl_synchronous, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/create_macro_vars_in_data_step_and_process_it_with_other_macro.sas:6 */

data r974o; rc=dosubl('data r974a; do x=1 to 5; output; end; run;');
dsid=open('r974a','i'); if dsid>0 then do; actual=attrn(dsid,'NLOBS'); rc=close(dsid); end; output; stop; run;

data _null_; if 0 then set r974o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R974 rows=' rows;
else do; set r974o; if not missing(actual) and abs(actual-(5))<=1e-10*max(1,abs(5)) then put 'ROUND2_PASS=R974';
else put 'ERROR: ROUND2_FAIL=R974 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r974:; quit;
