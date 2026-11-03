/* T1044 open_vartype, N=5; source: SAS-Useful-Codes/Macros/GetVarList.sas:117 */

data t1044a; length text $5; text='a'; value=5; run;
data t1044o; ds=open('t1044a','i'); actual=5+10*(vartype(ds,varnum(ds,'text'))='C'); rc=close(ds); run;

data _null_; if 0 then set t1044o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1044 rows=' rows;
else do; set t1044o; if not missing(actual) and abs(actual-(15))<=1e-10*max(1,abs(15)) then put 'ROUND3_PASS=T1044';
else put 'ERROR: ROUND3_FAIL=T1044 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1044:; quit;
