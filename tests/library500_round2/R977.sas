/* R977 dosubl_synchronous, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/create_macro_vars_in_data_step_and_process_it_with_other_macro.sas:6 */

data r977o; rc=dosubl('data r977a; do x=1 to 8; output; end; run;');
dsid=open('r977a','i'); if dsid>0 then do; actual=attrn(dsid,'NLOBS'); rc=close(dsid); end; output; stop; run;

data _null_; if 0 then set r977o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R977 rows=' rows;
else do; set r977o; if not missing(actual) and abs(actual-(8))<=1e-10*max(1,abs(8)) then put 'ROUND2_PASS=R977';
else put 'ERROR: ROUND2_FAIL=R977 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r977:; quit;
