/* T1073 attrn_record_length, N=4; source: SAS-Useful-Codes/Macros/GetVarList.sas:102 */

data t1073a; array x[4] v1-v4; do j=1 to 4; x[j]=j; end; drop j; run;
data t1073o; ds=open('t1073a','i'); actual=attrn(ds,'LRECL'); rc=close(ds); run;

data _null_; if 0 then set t1073o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1073 rows=' rows;
else do; set t1073o; if not missing(actual) and abs(actual-(32))<=1e-10*max(1,abs(32)) then put 'ROUND3_PASS=T1073';
else put 'ERROR: ROUND3_FAIL=T1073 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1073:; quit;
