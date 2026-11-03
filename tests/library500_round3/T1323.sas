/* T1323 sql_not_in_missing, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/proc_logistic_with_small_cohort_prunning2overfitting.sas:28 */

data t1323a; do x=1 to 4; output; end; x=.; output; run;
proc sql; create table t1323o as select sum(x) as actual from t1323a where x not in (.,4); quit;

data _null_; if 0 then set t1323o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1323 rows=' rows;
else do; set t1323o; if not missing(actual) and abs(actual-(6))<=1e-10*max(1,abs(6)) then put 'ROUND3_PASS=T1323';
else put 'ERROR: ROUND3_FAIL=T1323 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1323:; quit;
