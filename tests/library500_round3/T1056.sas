/* T1056 open_varlen, N=7; source: SAS-Useful-Codes/Macros/SAS-macros-master/ds2xls.sas:83 */

data t1056a; length text $12; text='a'; run;
data t1056o; ds=open('t1056a','i'); actual=varlen(ds,varnum(ds,'text')); rc=close(ds); run;

data _null_; if 0 then set t1056o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1056 rows=' rows;
else do; set t1056o; if not missing(actual) and abs(actual-(12))<=1e-10*max(1,abs(12)) then put 'ROUND3_PASS=T1056';
else put 'ERROR: ROUND3_FAIL=T1056 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1056:; quit;
