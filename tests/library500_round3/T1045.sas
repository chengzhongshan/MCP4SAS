/* T1045 open_vartype, N=6; source: SAS-Useful-Codes/Macros/GetVarList.sas:117 */

data t1045a; length text $6; text='a'; value=6; run;
data t1045o; ds=open('t1045a','i'); actual=6+10*(vartype(ds,varnum(ds,'text'))='C'); rc=close(ds); run;

data _null_; if 0 then set t1045o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1045 rows=' rows;
else do; set t1045o; if not missing(actual) and abs(actual-(16))<=1e-10*max(1,abs(16)) then put 'ROUND3_PASS=T1045';
else put 'ERROR: ROUND3_FAIL=T1045 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1045:; quit;
