/* T1052 open_varlen, N=3; source: SAS-Useful-Codes/Macros/SAS-macros-master/ds2xls.sas:83 */

data t1052a; length text $8; text='a'; run;
data t1052o; ds=open('t1052a','i'); actual=varlen(ds,varnum(ds,'text')); rc=close(ds); run;

data _null_; if 0 then set t1052o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1052 rows=' rows;
else do; set t1052o; if not missing(actual) and abs(actual-(8))<=1e-10*max(1,abs(8)) then put 'ROUND3_PASS=T1052';
else put 'ERROR: ROUND3_FAIL=T1052 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1052:; quit;
