/* T1039 open_varnum, N=10; source: SAS-Useful-Codes/Macros/GetVarAttrib.sas:52 */

data t1039a; array x[10] v1-v10; do j=1 to 10; x[j]=j; end; drop j; run;
data t1039o; ds=open('t1039a','i'); actual=varnum(ds,'v10'); rc=close(ds); run;

data _null_; if 0 then set t1039o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1039 rows=' rows;
else do; set t1039o; if not missing(actual) and abs(actual-(10))<=1e-10*max(1,abs(10)) then put 'ROUND3_PASS=T1039';
else put 'ERROR: ROUND3_FAIL=T1039 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1039:; quit;
