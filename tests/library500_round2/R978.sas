/* R978 dosubl_synchronous, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/create_macro_vars_in_data_step_and_process_it_with_other_macro.sas:6 */

data r978o; rc=dosubl('data r978a; do x=1 to 9; output; end; run;');
dsid=open('r978a','i'); if dsid>0 then do; actual=attrn(dsid,'NLOBS'); rc=close(dsid); end; output; stop; run;

data _null_; if 0 then set r978o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R978 rows=' rows;
else do; set r978o; if not missing(actual) and abs(actual-(9))<=1e-10*max(1,abs(9)) then put 'ROUND2_PASS=R978';
else put 'ERROR: ROUND2_FAIL=R978 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r978:; quit;
