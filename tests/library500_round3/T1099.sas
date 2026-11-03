/* T1099 dictionary_empty_table, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of _str_ and _prxchange_ in transfering space separated input into quoted and comma separated macro variable.sas:9 */

data t1099a; do x=1 to 10; output; end; run;
data t1099b; set t1099a(obs=0); run;
proc sql; create table t1099o as select sum(nobs) as actual from dictionary.tables where libname='WORK' and (memname=upcase('t1099a') or memname=upcase('t1099b')); quit;

data _null_; if 0 then set t1099o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1099 rows=' rows;
else do; set t1099o; if not missing(actual) and abs(actual-(10))<=1e-10*max(1,abs(10)) then put 'ROUND3_PASS=T1099';
else put 'ERROR: ROUND3_FAIL=T1099 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1099:; quit;
