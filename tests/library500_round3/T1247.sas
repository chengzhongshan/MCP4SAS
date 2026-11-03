/* T1247 freq_zero_weight, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/order_by_data_for_proc_freq_OR_calculation.sas:26 */

data t1247a; do grp=0 to 8; weight=grp; output; end; run;
proc freq data=t1247a noprint; tables grp / out=t1247b; weight weight / zeros; run;
proc sql; create table t1247o as select count(*) as actual from t1247b; quit;

data _null_; if 0 then set t1247o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1247 rows=' rows;
else do; set t1247o; if not missing(actual) and abs(actual-(9))<=1e-10*max(1,abs(9)) then put 'ROUND3_PASS=T1247';
else put 'ERROR: ROUND3_FAIL=T1247 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1247:; quit;
