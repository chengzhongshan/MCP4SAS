/* R972 dosubl_synchronous, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/create_macro_vars_in_data_step_and_process_it_with_other_macro.sas:6 */

data r972o; rc=dosubl('data r972a; do x=1 to 3; output; end; run;');
dsid=open('r972a','i'); if dsid>0 then do; actual=attrn(dsid,'NLOBS'); rc=close(dsid); end; output; stop; run;

data _null_; if 0 then set r972o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R972 rows=' rows;
else do; set r972o; if not missing(actual) and abs(actual-(3))<=1e-10*max(1,abs(3)) then put 'ROUND2_PASS=R972';
else put 'ERROR: ROUND2_FAIL=R972 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r972:; quit;
