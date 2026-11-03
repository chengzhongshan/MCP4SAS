/* T1097 dictionary_empty_table, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of _str_ and _prxchange_ in transfering space separated input into quoted and comma separated macro variable.sas:9 */

data t1097a; do x=1 to 8; output; end; run;
data t1097b; set t1097a(obs=0); run;
proc sql; create table t1097o as select sum(nobs) as actual from dictionary.tables where libname='WORK' and (memname=upcase('t1097a') or memname=upcase('t1097b')); quit;

data _null_; if 0 then set t1097o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1097 rows=' rows;
else do; set t1097o; if not missing(actual) and abs(actual-(8))<=1e-10*max(1,abs(8)) then put 'ROUND3_PASS=T1097';
else put 'ERROR: ROUND3_FAIL=T1097 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1097:; quit;
