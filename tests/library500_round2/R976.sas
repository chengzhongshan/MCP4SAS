/* R976 dosubl_synchronous, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/create_macro_vars_in_data_step_and_process_it_with_other_macro.sas:6 */

data r976o; rc=dosubl('data r976a; do x=1 to 7; output; end; run;');
dsid=open('r976a','i'); if dsid>0 then do; actual=attrn(dsid,'NLOBS'); rc=close(dsid); end; output; stop; run;

data _null_; if 0 then set r976o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R976 rows=' rows;
else do; set r976o; if not missing(actual) and abs(actual-(7))<=1e-10*max(1,abs(7)) then put 'ROUND2_PASS=R976';
else put 'ERROR: ROUND2_FAIL=R976 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r976:; quit;
