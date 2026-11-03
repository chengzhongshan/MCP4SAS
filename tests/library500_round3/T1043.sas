/* T1043 open_vartype, N=4; source: SAS-Useful-Codes/Macros/GetVarList.sas:117 */

data t1043a; length text $4; text='a'; value=4; run;
data t1043o; ds=open('t1043a','i'); actual=4+10*(vartype(ds,varnum(ds,'text'))='C'); rc=close(ds); run;

data _null_; if 0 then set t1043o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1043 rows=' rows;
else do; set t1043o; if not missing(actual) and abs(actual-(14))<=1e-10*max(1,abs(14)) then put 'ROUND3_PASS=T1043';
else put 'ERROR: ROUND3_FAIL=T1043 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1043:; quit;
