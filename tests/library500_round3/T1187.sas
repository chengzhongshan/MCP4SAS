/* T1187 append_force_extra_column, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro function qscan demo_scan black space separated words with special characters _ in it.sas:19 */

data t1187a; do x=1 to 8; output; end; run;
data t1187b; do x=1 to 8; extra=x; output; end; run;
proc append base=t1187a data=t1187b force; run;
proc sql; create table t1187o as select sum(x) as actual from t1187a; quit;

data _null_; if 0 then set t1187o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1187 rows=' rows;
else do; set t1187o; if not missing(actual) and abs(actual-(72))<=1e-10*max(1,abs(72)) then put 'ROUND3_PASS=T1187';
else put 'ERROR: ROUND3_FAIL=T1187 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1187:; quit;
