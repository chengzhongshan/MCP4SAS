/* T1098 dictionary_empty_table, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of _str_ and _prxchange_ in transfering space separated input into quoted and comma separated macro variable.sas:9 */

data t1098a; do x=1 to 9; output; end; run;
data t1098b; set t1098a(obs=0); run;
proc sql; create table t1098o as select sum(nobs) as actual from dictionary.tables where libname='WORK' and (memname=upcase('t1098a') or memname=upcase('t1098b')); quit;

data _null_; if 0 then set t1098o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1098 rows=' rows;
else do; set t1098o; if not missing(actual) and abs(actual-(9))<=1e-10*max(1,abs(9)) then put 'ROUND3_PASS=T1098';
else put 'ERROR: ROUND3_FAIL=T1098 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1098:; quit;
