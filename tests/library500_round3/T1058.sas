/* T1058 open_varlen, N=9; source: SAS-Useful-Codes/Macros/SAS-macros-master/ds2xls.sas:83 */

data t1058a; length text $14; text='a'; run;
data t1058o; ds=open('t1058a','i'); actual=varlen(ds,varnum(ds,'text')); rc=close(ds); run;

data _null_; if 0 then set t1058o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1058 rows=' rows;
else do; set t1058o; if not missing(actual) and abs(actual-(14))<=1e-10*max(1,abs(14)) then put 'ROUND3_PASS=T1058';
else put 'ERROR: ROUND3_FAIL=T1058 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1058:; quit;
