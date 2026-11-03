/* T1093 dictionary_empty_table, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of _str_ and _prxchange_ in transfering space separated input into quoted and comma separated macro variable.sas:9 */

data t1093a; do x=1 to 4; output; end; run;
data t1093b; set t1093a(obs=0); run;
proc sql; create table t1093o as select sum(nobs) as actual from dictionary.tables where libname='WORK' and (memname=upcase('t1093a') or memname=upcase('t1093b')); quit;

data _null_; if 0 then set t1093o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1093 rows=' rows;
else do; set t1093o; if not missing(actual) and abs(actual-(4))<=1e-10*max(1,abs(4)) then put 'ROUND3_PASS=T1093';
else put 'ERROR: ROUND3_FAIL=T1093 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1093:; quit;
