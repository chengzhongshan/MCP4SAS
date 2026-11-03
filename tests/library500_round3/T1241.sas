/* T1241 freq_zero_weight, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/order_by_data_for_proc_freq_OR_calculation.sas:26 */

data t1241a; do grp=0 to 2; weight=grp; output; end; run;
proc freq data=t1241a noprint; tables grp / out=t1241b; weight weight / zeros; run;
proc sql; create table t1241o as select count(*) as actual from t1241b; quit;

data _null_; if 0 then set t1241o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1241 rows=' rows;
else do; set t1241o; if not missing(actual) and abs(actual-(3))<=1e-10*max(1,abs(3)) then put 'ROUND3_PASS=T1241';
else put 'ERROR: ROUND3_FAIL=T1241 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1241:; quit;
