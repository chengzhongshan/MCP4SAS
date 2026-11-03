/* T1223 obs_zero_schema, N=4; source: SAS-Useful-Codes/Macros/ExpandVarList.sas:5 */

data t1223a; array x[4] v1-v4; do j=1 to 4; x[j]=j; end; drop j; run;
data t1223b; set t1223a(obs=0); run;
data t1223o; ds=open('t1223b','i'); actual=attrn(ds,'NVARS')+attrn(ds,'NLOBS'); rc=close(ds); run;

data _null_; if 0 then set t1223o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1223 rows=' rows;
else do; set t1223o; if not missing(actual) and abs(actual-(4))<=1e-10*max(1,abs(4)) then put 'ROUND3_PASS=T1223';
else put 'ERROR: ROUND3_FAIL=T1223 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1223:; quit;
