/* T1035 open_varnum, N=6; source: SAS-Useful-Codes/Macros/GetVarAttrib.sas:52 */

data t1035a; array x[6] v1-v6; do j=1 to 6; x[j]=j; end; drop j; run;
data t1035o; ds=open('t1035a','i'); actual=varnum(ds,'v6'); rc=close(ds); run;

data _null_; if 0 then set t1035o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1035 rows=' rows;
else do; set t1035o; if not missing(actual) and abs(actual-(6))<=1e-10*max(1,abs(6)) then put 'ROUND3_PASS=T1035';
else put 'ERROR: ROUND3_FAIL=T1035 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1035:; quit;
