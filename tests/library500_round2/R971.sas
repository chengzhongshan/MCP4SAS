/* R971 dosubl_synchronous, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/create_macro_vars_in_data_step_and_process_it_with_other_macro.sas:6 */

data r971o; rc=dosubl('data r971a; do x=1 to 2; output; end; run;');
dsid=open('r971a','i'); if dsid>0 then do; actual=attrn(dsid,'NLOBS'); rc=close(dsid); end; output; stop; run;

data _null_; if 0 then set r971o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R971 rows=' rows;
else do; set r971o; if not missing(actual) and abs(actual-(2))<=1e-10*max(1,abs(2)) then put 'ROUND2_PASS=R971';
else put 'ERROR: ROUND2_FAIL=R971 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r971:; quit;
