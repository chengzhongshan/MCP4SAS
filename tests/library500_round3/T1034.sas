/* T1034 open_varnum, N=5; source: SAS-Useful-Codes/Macros/GetVarAttrib.sas:52 */

data t1034a; array x[5] v1-v5; do j=1 to 5; x[j]=j; end; drop j; run;
data t1034o; ds=open('t1034a','i'); actual=varnum(ds,'v5'); rc=close(ds); run;

data _null_; if 0 then set t1034o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1034 rows=' rows;
else do; set t1034o; if not missing(actual) and abs(actual-(5))<=1e-10*max(1,abs(5)) then put 'ROUND3_PASS=T1034';
else put 'ERROR: ROUND3_FAIL=T1034 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1034:; quit;
