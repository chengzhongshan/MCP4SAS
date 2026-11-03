/* T1048 open_vartype, N=9; source: SAS-Useful-Codes/Macros/GetVarList.sas:117 */

data t1048a; length text $9; text='a'; value=9; run;
data t1048o; ds=open('t1048a','i'); actual=9+10*(vartype(ds,varnum(ds,'text'))='C'); rc=close(ds); run;

data _null_; if 0 then set t1048o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1048 rows=' rows;
else do; set t1048o; if not missing(actual) and abs(actual-(19))<=1e-10*max(1,abs(19)) then put 'ROUND3_PASS=T1048';
else put 'ERROR: ROUND3_FAIL=T1048 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1048:; quit;
