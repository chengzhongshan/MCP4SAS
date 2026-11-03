/* T1054 open_varlen, N=5; source: SAS-Useful-Codes/Macros/SAS-macros-master/ds2xls.sas:83 */

data t1054a; length text $10; text='a'; run;
data t1054o; ds=open('t1054a','i'); actual=varlen(ds,varnum(ds,'text')); rc=close(ds); run;

data _null_; if 0 then set t1054o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1054 rows=' rows;
else do; set t1054o; if not missing(actual) and abs(actual-(10))<=1e-10*max(1,abs(10)) then put 'ROUND3_PASS=T1054';
else put 'ERROR: ROUND3_FAIL=T1054 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1054:; quit;
