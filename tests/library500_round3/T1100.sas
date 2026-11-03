/* T1100 dictionary_empty_table, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of _str_ and _prxchange_ in transfering space separated input into quoted and comma separated macro variable.sas:9 */

data t1100a; do x=1 to 11; output; end; run;
data t1100b; set t1100a(obs=0); run;
proc sql; create table t1100o as select sum(nobs) as actual from dictionary.tables where libname='WORK' and (memname=upcase('t1100a') or memname=upcase('t1100b')); quit;

data _null_; if 0 then set t1100o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1100 rows=' rows;
else do; set t1100o; if not missing(actual) and abs(actual-(11))<=1e-10*max(1,abs(11)) then put 'ROUND3_PASS=T1100';
else put 'ERROR: ROUND3_FAIL=T1100 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1100:; quit;
