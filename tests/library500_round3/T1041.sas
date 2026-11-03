/* T1041 open_vartype, N=2; source: SAS-Useful-Codes/Macros/GetVarList.sas:117 */

data t1041a; length text $2; text='a'; value=2; run;
data t1041o; ds=open('t1041a','i'); actual=2+10*(vartype(ds,varnum(ds,'text'))='C'); rc=close(ds); run;

data _null_; if 0 then set t1041o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1041 rows=' rows;
else do; set t1041o; if not missing(actual) and abs(actual-(12))<=1e-10*max(1,abs(12)) then put 'ROUND3_PASS=T1041';
else put 'ERROR: ROUND3_FAIL=T1041 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1041:; quit;
