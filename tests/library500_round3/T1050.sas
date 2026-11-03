/* T1050 open_vartype, N=11; source: SAS-Useful-Codes/Macros/GetVarList.sas:117 */

data t1050a; length text $11; text='a'; value=11; run;
data t1050o; ds=open('t1050a','i'); actual=11+10*(vartype(ds,varnum(ds,'text'))='C'); rc=close(ds); run;

data _null_; if 0 then set t1050o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1050 rows=' rows;
else do; set t1050o; if not missing(actual) and abs(actual-(21))<=1e-10*max(1,abs(21)) then put 'ROUND3_PASS=T1050';
else put 'ERROR: ROUND3_FAIL=T1050 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1050:; quit;
