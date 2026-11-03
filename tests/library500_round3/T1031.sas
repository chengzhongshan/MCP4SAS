/* T1031 open_varnum, N=2; source: SAS-Useful-Codes/Macros/GetVarAttrib.sas:52 */

data t1031a; array x[2] v1-v2; do j=1 to 2; x[j]=j; end; drop j; run;
data t1031o; ds=open('t1031a','i'); actual=varnum(ds,'v2'); rc=close(ds); run;

data _null_; if 0 then set t1031o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1031 rows=' rows;
else do; set t1031o; if not missing(actual) and abs(actual-(2))<=1e-10*max(1,abs(2)) then put 'ROUND3_PASS=T1031';
else put 'ERROR: ROUND3_FAIL=T1031 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1031:; quit;
