/* T1057 open_varlen, N=8; source: SAS-Useful-Codes/Macros/SAS-macros-master/ds2xls.sas:83 */

data t1057a; length text $13; text='a'; run;
data t1057o; ds=open('t1057a','i'); actual=varlen(ds,varnum(ds,'text')); rc=close(ds); run;

data _null_; if 0 then set t1057o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1057 rows=' rows;
else do; set t1057o; if not missing(actual) and abs(actual-(13))<=1e-10*max(1,abs(13)) then put 'ROUND3_PASS=T1057';
else put 'ERROR: ROUND3_FAIL=T1057 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1057:; quit;
