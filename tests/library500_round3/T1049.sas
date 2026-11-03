/* T1049 open_vartype, N=10; source: SAS-Useful-Codes/Macros/GetVarList.sas:117 */

data t1049a; length text $10; text='a'; value=10; run;
data t1049o; ds=open('t1049a','i'); actual=10+10*(vartype(ds,varnum(ds,'text'))='C'); rc=close(ds); run;

data _null_; if 0 then set t1049o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1049 rows=' rows;
else do; set t1049o; if not missing(actual) and abs(actual-(20))<=1e-10*max(1,abs(20)) then put 'ROUND3_PASS=T1049';
else put 'ERROR: ROUND3_FAIL=T1049 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1049:; quit;
