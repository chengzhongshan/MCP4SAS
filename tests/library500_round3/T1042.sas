/* T1042 open_vartype, N=3; source: SAS-Useful-Codes/Macros/GetVarList.sas:117 */

data t1042a; length text $3; text='a'; value=3; run;
data t1042o; ds=open('t1042a','i'); actual=3+10*(vartype(ds,varnum(ds,'text'))='C'); rc=close(ds); run;

data _null_; if 0 then set t1042o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1042 rows=' rows;
else do; set t1042o; if not missing(actual) and abs(actual-(13))<=1e-10*max(1,abs(13)) then put 'ROUND3_PASS=T1042';
else put 'ERROR: ROUND3_FAIL=T1042 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1042:; quit;
