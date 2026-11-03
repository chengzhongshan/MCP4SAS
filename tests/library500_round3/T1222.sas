/* T1222 obs_zero_schema, N=3; source: SAS-Useful-Codes/Macros/ExpandVarList.sas:5 */

data t1222a; array x[3] v1-v3; do j=1 to 3; x[j]=j; end; drop j; run;
data t1222b; set t1222a(obs=0); run;
data t1222o; ds=open('t1222b','i'); actual=attrn(ds,'NVARS')+attrn(ds,'NLOBS'); rc=close(ds); run;

data _null_; if 0 then set t1222o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1222 rows=' rows;
else do; set t1222o; if not missing(actual) and abs(actual-(3))<=1e-10*max(1,abs(3)) then put 'ROUND3_PASS=T1222';
else put 'ERROR: ROUND3_FAIL=T1222 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1222:; quit;
