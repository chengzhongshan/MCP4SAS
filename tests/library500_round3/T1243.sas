/* T1243 freq_zero_weight, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/order_by_data_for_proc_freq_OR_calculation.sas:26 */

data t1243a; do grp=0 to 4; weight=grp; output; end; run;
proc freq data=t1243a noprint; tables grp / out=t1243b; weight weight / zeros; run;
proc sql; create table t1243o as select count(*) as actual from t1243b; quit;

data _null_; if 0 then set t1243o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1243 rows=' rows;
else do; set t1243o; if not missing(actual) and abs(actual-(5))<=1e-10*max(1,abs(5)) then put 'ROUND3_PASS=T1243';
else put 'ERROR: ROUND3_FAIL=T1243 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1243:; quit;
