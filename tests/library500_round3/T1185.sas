/* T1185 append_force_extra_column, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro function qscan demo_scan black space separated words with special characters _ in it.sas:19 */

data t1185a; do x=1 to 6; output; end; run;
data t1185b; do x=1 to 6; extra=x; output; end; run;
proc append base=t1185a data=t1185b force; run;
proc sql; create table t1185o as select sum(x) as actual from t1185a; quit;

data _null_; if 0 then set t1185o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1185 rows=' rows;
else do; set t1185o; if not missing(actual) and abs(actual-(42))<=1e-10*max(1,abs(42)) then put 'ROUND3_PASS=T1185';
else put 'ERROR: ROUND3_FAIL=T1185 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1185:; quit;
