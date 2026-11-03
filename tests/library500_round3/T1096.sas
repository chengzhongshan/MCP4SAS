/* T1096 dictionary_empty_table, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of _str_ and _prxchange_ in transfering space separated input into quoted and comma separated macro variable.sas:9 */

data t1096a; do x=1 to 7; output; end; run;
data t1096b; set t1096a(obs=0); run;
proc sql; create table t1096o as select sum(nobs) as actual from dictionary.tables where libname='WORK' and (memname=upcase('t1096a') or memname=upcase('t1096b')); quit;

data _null_; if 0 then set t1096o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1096 rows=' rows;
else do; set t1096o; if not missing(actual) and abs(actual-(7))<=1e-10*max(1,abs(7)) then put 'ROUND3_PASS=T1096';
else put 'ERROR: ROUND3_FAIL=T1096 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1096:; quit;
