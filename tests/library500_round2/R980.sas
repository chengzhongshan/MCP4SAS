/* R980 dosubl_synchronous, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/create_macro_vars_in_data_step_and_process_it_with_other_macro.sas:6 */

data r980o; rc=dosubl('data r980a; do x=1 to 11; output; end; run;');
dsid=open('r980a','i'); if dsid>0 then do; actual=attrn(dsid,'NLOBS'); rc=close(dsid); end; output; stop; run;

data _null_; if 0 then set r980o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R980 rows=' rows;
else do; set r980o; if not missing(actual) and abs(actual-(11))<=1e-10*max(1,abs(11)) then put 'ROUND2_PASS=R980';
else put 'ERROR: ROUND2_FAIL=R980 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r980:; quit;
