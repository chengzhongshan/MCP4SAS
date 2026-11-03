/* T1225 obs_zero_schema, N=6; source: SAS-Useful-Codes/Macros/ExpandVarList.sas:5 */

data t1225a; array x[6] v1-v6; do j=1 to 6; x[j]=j; end; drop j; run;
data t1225b; set t1225a(obs=0); run;
data t1225o; ds=open('t1225b','i'); actual=attrn(ds,'NVARS')+attrn(ds,'NLOBS'); rc=close(ds); run;

data _null_; if 0 then set t1225o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1225 rows=' rows;
else do; set t1225o; if not missing(actual) and abs(actual-(6))<=1e-10*max(1,abs(6)) then put 'ROUND3_PASS=T1225';
else put 'ERROR: ROUND3_FAIL=T1225 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1225:; quit;
