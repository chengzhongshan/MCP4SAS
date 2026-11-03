/* T1325 sql_not_in_missing, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/proc_logistic_with_small_cohort_prunning2overfitting.sas:28 */

data t1325a; do x=1 to 6; output; end; x=.; output; run;
proc sql; create table t1325o as select sum(x) as actual from t1325a where x not in (.,6); quit;

data _null_; if 0 then set t1325o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1325 rows=' rows;
else do; set t1325o; if not missing(actual) and abs(actual-(15))<=1e-10*max(1,abs(15)) then put 'ROUND3_PASS=T1325';
else put 'ERROR: ROUND3_FAIL=T1325 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1325:; quit;
