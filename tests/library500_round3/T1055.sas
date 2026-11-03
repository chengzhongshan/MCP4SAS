/* T1055 open_varlen, N=6; source: SAS-Useful-Codes/Macros/SAS-macros-master/ds2xls.sas:83 */

data t1055a; length text $11; text='a'; run;
data t1055o; ds=open('t1055a','i'); actual=varlen(ds,varnum(ds,'text')); rc=close(ds); run;

data _null_; if 0 then set t1055o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1055 rows=' rows;
else do; set t1055o; if not missing(actual) and abs(actual-(11))<=1e-10*max(1,abs(11)) then put 'ROUND3_PASS=T1055';
else put 'ERROR: ROUND3_FAIL=T1055 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1055:; quit;
