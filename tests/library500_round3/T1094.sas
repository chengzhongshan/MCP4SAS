/* T1094 dictionary_empty_table, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of _str_ and _prxchange_ in transfering space separated input into quoted and comma separated macro variable.sas:9 */

data t1094a; do x=1 to 5; output; end; run;
data t1094b; set t1094a(obs=0); run;
proc sql; create table t1094o as select sum(nobs) as actual from dictionary.tables where libname='WORK' and (memname=upcase('t1094a') or memname=upcase('t1094b')); quit;

data _null_; if 0 then set t1094o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1094 rows=' rows;
else do; set t1094o; if not missing(actual) and abs(actual-(5))<=1e-10*max(1,abs(5)) then put 'ROUND3_PASS=T1094';
else put 'ERROR: ROUND3_FAIL=T1094 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1094:; quit;
