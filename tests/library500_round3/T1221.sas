/* T1221 obs_zero_schema, N=2; source: SAS-Useful-Codes/Macros/ExpandVarList.sas:5 */

data t1221a; array x[2] v1-v2; do j=1 to 2; x[j]=j; end; drop j; run;
data t1221b; set t1221a(obs=0); run;
data t1221o; ds=open('t1221b','i'); actual=attrn(ds,'NVARS')+attrn(ds,'NLOBS'); rc=close(ds); run;

data _null_; if 0 then set t1221o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1221 rows=' rows;
else do; set t1221o; if not missing(actual) and abs(actual-(2))<=1e-10*max(1,abs(2)) then put 'ROUND3_PASS=T1221';
else put 'ERROR: ROUND3_FAIL=T1221 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1221:; quit;
