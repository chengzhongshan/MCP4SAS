/* T1229 obs_zero_schema, N=10; source: SAS-Useful-Codes/Macros/ExpandVarList.sas:5 */

data t1229a; array x[10] v1-v10; do j=1 to 10; x[j]=j; end; drop j; run;
data t1229b; set t1229a(obs=0); run;
data t1229o; ds=open('t1229b','i'); actual=attrn(ds,'NVARS')+attrn(ds,'NLOBS'); rc=close(ds); run;

data _null_; if 0 then set t1229o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1229 rows=' rows;
else do; set t1229o; if not missing(actual) and abs(actual-(10))<=1e-10*max(1,abs(10)) then put 'ROUND3_PASS=T1229';
else put 'ERROR: ROUND3_FAIL=T1229 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1229:; quit;
