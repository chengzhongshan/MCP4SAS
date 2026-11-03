/* T1051 open_varlen, N=2; source: SAS-Useful-Codes/Macros/SAS-macros-master/ds2xls.sas:83 */

data t1051a; length text $7; text='a'; run;
data t1051o; ds=open('t1051a','i'); actual=varlen(ds,varnum(ds,'text')); rc=close(ds); run;

data _null_; if 0 then set t1051o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1051 rows=' rows;
else do; set t1051o; if not missing(actual) and abs(actual-(7))<=1e-10*max(1,abs(7)) then put 'ROUND3_PASS=T1051';
else put 'ERROR: ROUND3_FAIL=T1051 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1051:; quit;
