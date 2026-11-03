/* T1249 freq_zero_weight, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/order_by_data_for_proc_freq_OR_calculation.sas:26 */

data t1249a; do grp=0 to 10; weight=grp; output; end; run;
proc freq data=t1249a noprint; tables grp / out=t1249b; weight weight / zeros; run;
proc sql; create table t1249o as select count(*) as actual from t1249b; quit;

data _null_; if 0 then set t1249o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1249 rows=' rows;
else do; set t1249o; if not missing(actual) and abs(actual-(11))<=1e-10*max(1,abs(11)) then put 'ROUND3_PASS=T1249';
else put 'ERROR: ROUND3_FAIL=T1249 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1249:; quit;
