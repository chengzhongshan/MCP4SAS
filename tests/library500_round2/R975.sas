/* R975 dosubl_synchronous, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/create_macro_vars_in_data_step_and_process_it_with_other_macro.sas:6 */

data r975o; rc=dosubl('data r975a; do x=1 to 6; output; end; run;');
dsid=open('r975a','i'); if dsid>0 then do; actual=attrn(dsid,'NLOBS'); rc=close(dsid); end; output; stop; run;

data _null_; if 0 then set r975o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R975 rows=' rows;
else do; set r975o; if not missing(actual) and abs(actual-(6))<=1e-10*max(1,abs(6)) then put 'ROUND2_PASS=R975';
else put 'ERROR: ROUND2_FAIL=R975 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r975:; quit;
