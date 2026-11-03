/* T1078 attrn_record_length, N=9; source: SAS-Useful-Codes/Macros/GetVarList.sas:102 */

data t1078a; array x[9] v1-v9; do j=1 to 9; x[j]=j; end; drop j; run;
data t1078o; ds=open('t1078a','i'); actual=attrn(ds,'LRECL'); rc=close(ds); run;

data _null_; if 0 then set t1078o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1078 rows=' rows;
else do; set t1078o; if not missing(actual) and abs(actual-(72))<=1e-10*max(1,abs(72)) then put 'ROUND3_PASS=T1078';
else put 'ERROR: ROUND3_FAIL=T1078 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1078:; quit;
