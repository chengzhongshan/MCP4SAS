/* T1230 obs_zero_schema, N=11; source: SAS-Useful-Codes/Macros/ExpandVarList.sas:5 */

data t1230a; array x[11] v1-v11; do j=1 to 11; x[j]=j; end; drop j; run;
data t1230b; set t1230a(obs=0); run;
data t1230o; ds=open('t1230b','i'); actual=attrn(ds,'NVARS')+attrn(ds,'NLOBS'); rc=close(ds); run;

data _null_; if 0 then set t1230o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1230 rows=' rows;
else do; set t1230o; if not missing(actual) and abs(actual-(11))<=1e-10*max(1,abs(11)) then put 'ROUND3_PASS=T1230';
else put 'ERROR: ROUND3_FAIL=T1230 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1230:; quit;
