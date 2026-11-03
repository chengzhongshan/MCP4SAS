/* T1227 obs_zero_schema, N=8; source: SAS-Useful-Codes/Macros/ExpandVarList.sas:5 */

data t1227a; array x[8] v1-v8; do j=1 to 8; x[j]=j; end; drop j; run;
data t1227b; set t1227a(obs=0); run;
data t1227o; ds=open('t1227b','i'); actual=attrn(ds,'NVARS')+attrn(ds,'NLOBS'); rc=close(ds); run;

data _null_; if 0 then set t1227o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1227 rows=' rows;
else do; set t1227o; if not missing(actual) and abs(actual-(8))<=1e-10*max(1,abs(8)) then put 'ROUND3_PASS=T1227';
else put 'ERROR: ROUND3_FAIL=T1227 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1227:; quit;
