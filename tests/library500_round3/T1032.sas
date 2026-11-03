/* T1032 open_varnum, N=3; source: SAS-Useful-Codes/Macros/GetVarAttrib.sas:52 */

data t1032a; array x[3] v1-v3; do j=1 to 3; x[j]=j; end; drop j; run;
data t1032o; ds=open('t1032a','i'); actual=varnum(ds,'v3'); rc=close(ds); run;

data _null_; if 0 then set t1032o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1032 rows=' rows;
else do; set t1032o; if not missing(actual) and abs(actual-(3))<=1e-10*max(1,abs(3)) then put 'ROUND3_PASS=T1032';
else put 'ERROR: ROUND3_FAIL=T1032 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1032:; quit;
