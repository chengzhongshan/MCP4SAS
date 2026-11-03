/* T1181 append_force_extra_column, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro function qscan demo_scan black space separated words with special characters _ in it.sas:19 */

data t1181a; do x=1 to 2; output; end; run;
data t1181b; do x=1 to 2; extra=x; output; end; run;
proc append base=t1181a data=t1181b force; run;
proc sql; create table t1181o as select sum(x) as actual from t1181a; quit;

data _null_; if 0 then set t1181o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1181 rows=' rows;
else do; set t1181o; if not missing(actual) and abs(actual-(6))<=1e-10*max(1,abs(6)) then put 'ROUND3_PASS=T1181';
else put 'ERROR: ROUND3_FAIL=T1181 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1181:; quit;
