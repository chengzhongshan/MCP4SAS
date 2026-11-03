/* T1037 open_varnum, N=8; source: SAS-Useful-Codes/Macros/GetVarAttrib.sas:52 */

data t1037a; array x[8] v1-v8; do j=1 to 8; x[j]=j; end; drop j; run;
data t1037o; ds=open('t1037a','i'); actual=varnum(ds,'v8'); rc=close(ds); run;

data _null_; if 0 then set t1037o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1037 rows=' rows;
else do; set t1037o; if not missing(actual) and abs(actual-(8))<=1e-10*max(1,abs(8)) then put 'ROUND3_PASS=T1037';
else put 'ERROR: ROUND3_FAIL=T1037 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1037:; quit;
