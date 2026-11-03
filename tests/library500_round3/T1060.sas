/* T1060 open_varlen, N=11; source: SAS-Useful-Codes/Macros/SAS-macros-master/ds2xls.sas:83 */

data t1060a; length text $16; text='a'; run;
data t1060o; ds=open('t1060a','i'); actual=varlen(ds,varnum(ds,'text')); rc=close(ds); run;

data _null_; if 0 then set t1060o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1060 rows=' rows;
else do; set t1060o; if not missing(actual) and abs(actual-(16))<=1e-10*max(1,abs(16)) then put 'ROUND3_PASS=T1060';
else put 'ERROR: ROUND3_FAIL=T1060 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1060:; quit;
