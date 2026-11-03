/* T1184 append_force_extra_column, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro function qscan demo_scan black space separated words with special characters _ in it.sas:19 */

data t1184a; do x=1 to 5; output; end; run;
data t1184b; do x=1 to 5; extra=x; output; end; run;
proc append base=t1184a data=t1184b force; run;
proc sql; create table t1184o as select sum(x) as actual from t1184a; quit;

data _null_; if 0 then set t1184o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1184 rows=' rows;
else do; set t1184o; if not missing(actual) and abs(actual-(30))<=1e-10*max(1,abs(30)) then put 'ROUND3_PASS=T1184';
else put 'ERROR: ROUND3_FAIL=T1184 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1184:; quit;
