/* T1190 append_force_extra_column, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro function qscan demo_scan black space separated words with special characters _ in it.sas:19 */

data t1190a; do x=1 to 11; output; end; run;
data t1190b; do x=1 to 11; extra=x; output; end; run;
proc append base=t1190a data=t1190b force; run;
proc sql; create table t1190o as select sum(x) as actual from t1190a; quit;

data _null_; if 0 then set t1190o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1190 rows=' rows;
else do; set t1190o; if not missing(actual) and abs(actual-(132))<=1e-10*max(1,abs(132)) then put 'ROUND3_PASS=T1190';
else put 'ERROR: ROUND3_FAIL=T1190 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1190:; quit;
