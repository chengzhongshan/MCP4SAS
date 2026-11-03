/* T1091 dictionary_empty_table, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of _str_ and _prxchange_ in transfering space separated input into quoted and comma separated macro variable.sas:9 */

data t1091a; do x=1 to 2; output; end; run;
data t1091b; set t1091a(obs=0); run;
proc sql; create table t1091o as select sum(nobs) as actual from dictionary.tables where libname='WORK' and (memname=upcase('t1091a') or memname=upcase('t1091b')); quit;

data _null_; if 0 then set t1091o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1091 rows=' rows;
else do; set t1091o; if not missing(actual) and abs(actual-(2))<=1e-10*max(1,abs(2)) then put 'ROUND3_PASS=T1091';
else put 'ERROR: ROUND3_FAIL=T1091 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1091:; quit;
