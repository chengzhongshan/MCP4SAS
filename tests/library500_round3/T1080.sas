/* T1080 attrn_record_length, N=11; source: SAS-Useful-Codes/Macros/GetVarList.sas:102 */

data t1080a; array x[11] v1-v11; do j=1 to 11; x[j]=j; end; drop j; run;
data t1080o; ds=open('t1080a','i'); actual=attrn(ds,'LRECL'); rc=close(ds); run;

data _null_; if 0 then set t1080o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1080 rows=' rows;
else do; set t1080o; if not missing(actual) and abs(actual-(88))<=1e-10*max(1,abs(88)) then put 'ROUND3_PASS=T1080';
else put 'ERROR: ROUND3_FAIL=T1080 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1080:; quit;
