/* R973 dosubl_synchronous, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/create_macro_vars_in_data_step_and_process_it_with_other_macro.sas:6 */

data r973o; rc=dosubl('data r973a; do x=1 to 4; output; end; run;');
dsid=open('r973a','i'); if dsid>0 then do; actual=attrn(dsid,'NLOBS'); rc=close(dsid); end; output; stop; run;

data _null_; if 0 then set r973o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R973 rows=' rows;
else do; set r973o; if not missing(actual) and abs(actual-(4))<=1e-10*max(1,abs(4)) then put 'ROUND2_PASS=R973';
else put 'ERROR: ROUND2_FAIL=R973 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r973:; quit;
