/* T1077 attrn_record_length, N=8; source: SAS-Useful-Codes/Macros/GetVarList.sas:102 */

data t1077a; array x[8] v1-v8; do j=1 to 8; x[j]=j; end; drop j; run;
data t1077o; ds=open('t1077a','i'); actual=attrn(ds,'LRECL'); rc=close(ds); run;

data _null_; if 0 then set t1077o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1077 rows=' rows;
else do; set t1077o; if not missing(actual) and abs(actual-(64))<=1e-10*max(1,abs(64)) then put 'ROUND3_PASS=T1077';
else put 'ERROR: ROUND3_FAIL=T1077 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1077:; quit;
