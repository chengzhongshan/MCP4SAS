/* T1244 freq_zero_weight, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/order_by_data_for_proc_freq_OR_calculation.sas:26 */

data t1244a; do grp=0 to 5; weight=grp; output; end; run;
proc freq data=t1244a noprint; tables grp / out=t1244b; weight weight / zeros; run;
proc sql; create table t1244o as select count(*) as actual from t1244b; quit;

data _null_; if 0 then set t1244o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1244 rows=' rows;
else do; set t1244o; if not missing(actual) and abs(actual-(6))<=1e-10*max(1,abs(6)) then put 'ROUND3_PASS=T1244';
else put 'ERROR: ROUND3_FAIL=T1244 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1244:; quit;
