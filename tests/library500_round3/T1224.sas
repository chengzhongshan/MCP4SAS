/* T1224 obs_zero_schema, N=5; source: SAS-Useful-Codes/Macros/ExpandVarList.sas:5 */

data t1224a; array x[5] v1-v5; do j=1 to 5; x[j]=j; end; drop j; run;
data t1224b; set t1224a(obs=0); run;
data t1224o; ds=open('t1224b','i'); actual=attrn(ds,'NVARS')+attrn(ds,'NLOBS'); rc=close(ds); run;

data _null_; if 0 then set t1224o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1224 rows=' rows;
else do; set t1224o; if not missing(actual) and abs(actual-(5))<=1e-10*max(1,abs(5)) then put 'ROUND3_PASS=T1224';
else put 'ERROR: ROUND3_FAIL=T1224 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1224:; quit;
