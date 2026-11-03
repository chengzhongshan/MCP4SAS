/* T1246 freq_zero_weight, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/order_by_data_for_proc_freq_OR_calculation.sas:26 */

data t1246a; do grp=0 to 7; weight=grp; output; end; run;
proc freq data=t1246a noprint; tables grp / out=t1246b; weight weight / zeros; run;
proc sql; create table t1246o as select count(*) as actual from t1246b; quit;

data _null_; if 0 then set t1246o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1246 rows=' rows;
else do; set t1246o; if not missing(actual) and abs(actual-(8))<=1e-10*max(1,abs(8)) then put 'ROUND3_PASS=T1246';
else put 'ERROR: ROUND3_FAIL=T1246 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1246:; quit;
