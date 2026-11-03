/* T1046 open_vartype, N=7; source: SAS-Useful-Codes/Macros/GetVarList.sas:117 */

data t1046a; length text $7; text='a'; value=7; run;
data t1046o; ds=open('t1046a','i'); actual=7+10*(vartype(ds,varnum(ds,'text'))='C'); rc=close(ds); run;

data _null_; if 0 then set t1046o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1046 rows=' rows;
else do; set t1046o; if not missing(actual) and abs(actual-(17))<=1e-10*max(1,abs(17)) then put 'ROUND3_PASS=T1046';
else put 'ERROR: ROUND3_FAIL=T1046 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1046:; quit;
