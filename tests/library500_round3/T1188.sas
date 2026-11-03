/* T1188 append_force_extra_column, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro function qscan demo_scan black space separated words with special characters _ in it.sas:19 */

data t1188a; do x=1 to 9; output; end; run;
data t1188b; do x=1 to 9; extra=x; output; end; run;
proc append base=t1188a data=t1188b force; run;
proc sql; create table t1188o as select sum(x) as actual from t1188a; quit;

data _null_; if 0 then set t1188o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1188 rows=' rows;
else do; set t1188o; if not missing(actual) and abs(actual-(90))<=1e-10*max(1,abs(90)) then put 'ROUND3_PASS=T1188';
else put 'ERROR: ROUND3_FAIL=T1188 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1188:; quit;
