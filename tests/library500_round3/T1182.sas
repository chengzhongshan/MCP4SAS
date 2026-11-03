/* T1182 append_force_extra_column, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro function qscan demo_scan black space separated words with special characters _ in it.sas:19 */

data t1182a; do x=1 to 3; output; end; run;
data t1182b; do x=1 to 3; extra=x; output; end; run;
proc append base=t1182a data=t1182b force; run;
proc sql; create table t1182o as select sum(x) as actual from t1182a; quit;

data _null_; if 0 then set t1182o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1182 rows=' rows;
else do; set t1182o; if not missing(actual) and abs(actual-(12))<=1e-10*max(1,abs(12)) then put 'ROUND3_PASS=T1182';
else put 'ERROR: ROUND3_FAIL=T1182 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1182:; quit;
