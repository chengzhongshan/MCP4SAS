/* T1092 dictionary_empty_table, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of _str_ and _prxchange_ in transfering space separated input into quoted and comma separated macro variable.sas:9 */

data t1092a; do x=1 to 3; output; end; run;
data t1092b; set t1092a(obs=0); run;
proc sql; create table t1092o as select sum(nobs) as actual from dictionary.tables where libname='WORK' and (memname=upcase('t1092a') or memname=upcase('t1092b')); quit;

data _null_; if 0 then set t1092o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1092 rows=' rows;
else do; set t1092o; if not missing(actual) and abs(actual-(3))<=1e-10*max(1,abs(3)) then put 'ROUND3_PASS=T1092';
else put 'ERROR: ROUND3_FAIL=T1092 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1092:; quit;
