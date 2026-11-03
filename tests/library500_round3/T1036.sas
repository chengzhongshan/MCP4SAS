/* T1036 open_varnum, N=7; source: SAS-Useful-Codes/Macros/GetVarAttrib.sas:52 */

data t1036a; array x[7] v1-v7; do j=1 to 7; x[j]=j; end; drop j; run;
data t1036o; ds=open('t1036a','i'); actual=varnum(ds,'v7'); rc=close(ds); run;

data _null_; if 0 then set t1036o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1036 rows=' rows;
else do; set t1036o; if not missing(actual) and abs(actual-(7))<=1e-10*max(1,abs(7)) then put 'ROUND3_PASS=T1036';
else put 'ERROR: ROUND3_FAIL=T1036 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1036:; quit;
