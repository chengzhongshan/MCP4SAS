/* T1047 open_vartype, N=8; source: SAS-Useful-Codes/Macros/GetVarList.sas:117 */

data t1047a; length text $8; text='a'; value=8; run;
data t1047o; ds=open('t1047a','i'); actual=8+10*(vartype(ds,varnum(ds,'text'))='C'); rc=close(ds); run;

data _null_; if 0 then set t1047o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1047 rows=' rows;
else do; set t1047o; if not missing(actual) and abs(actual-(18))<=1e-10*max(1,abs(18)) then put 'ROUND3_PASS=T1047';
else put 'ERROR: ROUND3_FAIL=T1047 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1047:; quit;
