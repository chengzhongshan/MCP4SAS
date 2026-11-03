/* T1071 attrn_record_length, N=2; source: SAS-Useful-Codes/Macros/GetVarList.sas:102 */

data t1071a; array x[2] v1-v2; do j=1 to 2; x[j]=j; end; drop j; run;
data t1071o; ds=open('t1071a','i'); actual=attrn(ds,'LRECL'); rc=close(ds); run;

data _null_; if 0 then set t1071o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1071 rows=' rows;
else do; set t1071o; if not missing(actual) and abs(actual-(16))<=1e-10*max(1,abs(16)) then put 'ROUND3_PASS=T1071';
else put 'ERROR: ROUND3_FAIL=T1071 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1071:; quit;
