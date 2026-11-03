/* T1076 attrn_record_length, N=7; source: SAS-Useful-Codes/Macros/GetVarList.sas:102 */

data t1076a; array x[7] v1-v7; do j=1 to 7; x[j]=j; end; drop j; run;
data t1076o; ds=open('t1076a','i'); actual=attrn(ds,'LRECL'); rc=close(ds); run;

data _null_; if 0 then set t1076o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1076 rows=' rows;
else do; set t1076o; if not missing(actual) and abs(actual-(56))<=1e-10*max(1,abs(56)) then put 'ROUND3_PASS=T1076';
else put 'ERROR: ROUND3_FAIL=T1076 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1076:; quit;
