/* T1226 obs_zero_schema, N=7; source: SAS-Useful-Codes/Macros/ExpandVarList.sas:5 */

data t1226a; array x[7] v1-v7; do j=1 to 7; x[j]=j; end; drop j; run;
data t1226b; set t1226a(obs=0); run;
data t1226o; ds=open('t1226b','i'); actual=attrn(ds,'NVARS')+attrn(ds,'NLOBS'); rc=close(ds); run;

data _null_; if 0 then set t1226o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1226 rows=' rows;
else do; set t1226o; if not missing(actual) and abs(actual-(7))<=1e-10*max(1,abs(7)) then put 'ROUND3_PASS=T1226';
else put 'ERROR: ROUND3_FAIL=T1226 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1226:; quit;
