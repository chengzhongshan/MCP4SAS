/* R979 dosubl_synchronous, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/create_macro_vars_in_data_step_and_process_it_with_other_macro.sas:6 */

data r979o; rc=dosubl('data r979a; do x=1 to 10; output; end; run;');
dsid=open('r979a','i'); if dsid>0 then do; actual=attrn(dsid,'NLOBS'); rc=close(dsid); end; output; stop; run;

data _null_; if 0 then set r979o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R979 rows=' rows;
else do; set r979o; if not missing(actual) and abs(actual-(10))<=1e-10*max(1,abs(10)) then put 'ROUND2_PASS=R979';
else put 'ERROR: ROUND2_FAIL=R979 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r979:; quit;
