/* T1321 sql_not_in_missing, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/proc_logistic_with_small_cohort_prunning2overfitting.sas:28 */

data t1321a; do x=1 to 2; output; end; x=.; output; run;
proc sql; create table t1321o as select sum(x) as actual from t1321a where x not in (.,2); quit;

data _null_; if 0 then set t1321o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1321 rows=' rows;
else do; set t1321o; if not missing(actual) and abs(actual-(1))<=1e-10*max(1,abs(1)) then put 'ROUND3_PASS=T1321';
else put 'ERROR: ROUND3_FAIL=T1321 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1321:; quit;
