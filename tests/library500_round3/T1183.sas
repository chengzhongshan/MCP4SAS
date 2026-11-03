/* T1183 append_force_extra_column, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro function qscan demo_scan black space separated words with special characters _ in it.sas:19 */

data t1183a; do x=1 to 4; output; end; run;
data t1183b; do x=1 to 4; extra=x; output; end; run;
proc append base=t1183a data=t1183b force; run;
proc sql; create table t1183o as select sum(x) as actual from t1183a; quit;

data _null_; if 0 then set t1183o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1183 rows=' rows;
else do; set t1183o; if not missing(actual) and abs(actual-(20))<=1e-10*max(1,abs(20)) then put 'ROUND3_PASS=T1183';
else put 'ERROR: ROUND3_FAIL=T1183 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1183:; quit;
