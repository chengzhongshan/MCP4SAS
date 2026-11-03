/* T1228 obs_zero_schema, N=9; source: SAS-Useful-Codes/Macros/ExpandVarList.sas:5 */

data t1228a; array x[9] v1-v9; do j=1 to 9; x[j]=j; end; drop j; run;
data t1228b; set t1228a(obs=0); run;
data t1228o; ds=open('t1228b','i'); actual=attrn(ds,'NVARS')+attrn(ds,'NLOBS'); rc=close(ds); run;

data _null_; if 0 then set t1228o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1228 rows=' rows;
else do; set t1228o; if not missing(actual) and abs(actual-(9))<=1e-10*max(1,abs(9)) then put 'ROUND3_PASS=T1228';
else put 'ERROR: ROUND3_FAIL=T1228 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1228:; quit;
