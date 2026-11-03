/* T1053 open_varlen, N=4; source: SAS-Useful-Codes/Macros/SAS-macros-master/ds2xls.sas:83 */

data t1053a; length text $9; text='a'; run;
data t1053o; ds=open('t1053a','i'); actual=varlen(ds,varnum(ds,'text')); rc=close(ds); run;

data _null_; if 0 then set t1053o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1053 rows=' rows;
else do; set t1053o; if not missing(actual) and abs(actual-(9))<=1e-10*max(1,abs(9)) then put 'ROUND3_PASS=T1053';
else put 'ERROR: ROUND3_FAIL=T1053 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1053:; quit;
