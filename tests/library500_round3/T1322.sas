/* T1322 sql_not_in_missing, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/proc_logistic_with_small_cohort_prunning2overfitting.sas:28 */

data t1322a; do x=1 to 3; output; end; x=.; output; run;
proc sql; create table t1322o as select sum(x) as actual from t1322a where x not in (.,3); quit;

data _null_; if 0 then set t1322o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1322 rows=' rows;
else do; set t1322o; if not missing(actual) and abs(actual-(3))<=1e-10*max(1,abs(3)) then put 'ROUND3_PASS=T1322';
else put 'ERROR: ROUND3_FAIL=T1322 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1322:; quit;
