/* T1328 sql_not_in_missing, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/proc_logistic_with_small_cohort_prunning2overfitting.sas:28 */

data t1328a; do x=1 to 9; output; end; x=.; output; run;
proc sql; create table t1328o as select sum(x) as actual from t1328a where x not in (.,9); quit;

data _null_; if 0 then set t1328o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1328 rows=' rows;
else do; set t1328o; if not missing(actual) and abs(actual-(36))<=1e-10*max(1,abs(36)) then put 'ROUND3_PASS=T1328';
else put 'ERROR: ROUND3_FAIL=T1328 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1328:; quit;
