/* T1189 append_force_extra_column, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro function qscan demo_scan black space separated words with special characters _ in it.sas:19 */

data t1189a; do x=1 to 10; output; end; run;
data t1189b; do x=1 to 10; extra=x; output; end; run;
proc append base=t1189a data=t1189b force; run;
proc sql; create table t1189o as select sum(x) as actual from t1189a; quit;

data _null_; if 0 then set t1189o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1189 rows=' rows;
else do; set t1189o; if not missing(actual) and abs(actual-(110))<=1e-10*max(1,abs(110)) then put 'ROUND3_PASS=T1189';
else put 'ERROR: ROUND3_FAIL=T1189 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1189:; quit;
