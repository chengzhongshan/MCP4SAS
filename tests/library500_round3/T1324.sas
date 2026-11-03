/* T1324 sql_not_in_missing, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/proc_logistic_with_small_cohort_prunning2overfitting.sas:28 */

data t1324a; do x=1 to 5; output; end; x=.; output; run;
proc sql; create table t1324o as select sum(x) as actual from t1324a where x not in (.,5); quit;

data _null_; if 0 then set t1324o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1324 rows=' rows;
else do; set t1324o; if not missing(actual) and abs(actual-(10))<=1e-10*max(1,abs(10)) then put 'ROUND3_PASS=T1324';
else put 'ERROR: ROUND3_FAIL=T1324 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1324:; quit;
