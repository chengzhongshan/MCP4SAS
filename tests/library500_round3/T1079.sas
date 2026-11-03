/* T1079 attrn_record_length, N=10; source: SAS-Useful-Codes/Macros/GetVarList.sas:102 */

data t1079a; array x[10] v1-v10; do j=1 to 10; x[j]=j; end; drop j; run;
data t1079o; ds=open('t1079a','i'); actual=attrn(ds,'LRECL'); rc=close(ds); run;

data _null_; if 0 then set t1079o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1079 rows=' rows;
else do; set t1079o; if not missing(actual) and abs(actual-(80))<=1e-10*max(1,abs(80)) then put 'ROUND3_PASS=T1079';
else put 'ERROR: ROUND3_FAIL=T1079 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1079:; quit;
