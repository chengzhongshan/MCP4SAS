/* T1059 open_varlen, N=10; source: SAS-Useful-Codes/Macros/SAS-macros-master/ds2xls.sas:83 */

data t1059a; length text $15; text='a'; run;
data t1059o; ds=open('t1059a','i'); actual=varlen(ds,varnum(ds,'text')); rc=close(ds); run;

data _null_; if 0 then set t1059o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1059 rows=' rows;
else do; set t1059o; if not missing(actual) and abs(actual-(15))<=1e-10*max(1,abs(15)) then put 'ROUND3_PASS=T1059';
else put 'ERROR: ROUND3_FAIL=T1059 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1059:; quit;
