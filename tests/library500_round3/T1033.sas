/* T1033 open_varnum, N=4; source: SAS-Useful-Codes/Macros/GetVarAttrib.sas:52 */

data t1033a; array x[4] v1-v4; do j=1 to 4; x[j]=j; end; drop j; run;
data t1033o; ds=open('t1033a','i'); actual=varnum(ds,'v4'); rc=close(ds); run;

data _null_; if 0 then set t1033o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1033 rows=' rows;
else do; set t1033o; if not missing(actual) and abs(actual-(4))<=1e-10*max(1,abs(4)) then put 'ROUND3_PASS=T1033';
else put 'ERROR: ROUND3_FAIL=T1033 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1033:; quit;
