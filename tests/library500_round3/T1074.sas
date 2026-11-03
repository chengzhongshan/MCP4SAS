/* T1074 attrn_record_length, N=5; source: SAS-Useful-Codes/Macros/GetVarList.sas:102 */

data t1074a; array x[5] v1-v5; do j=1 to 5; x[j]=j; end; drop j; run;
data t1074o; ds=open('t1074a','i'); actual=attrn(ds,'LRECL'); rc=close(ds); run;

data _null_; if 0 then set t1074o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1074 rows=' rows;
else do; set t1074o; if not missing(actual) and abs(actual-(40))<=1e-10*max(1,abs(40)) then put 'ROUND3_PASS=T1074';
else put 'ERROR: ROUND3_FAIL=T1074 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1074:; quit;
