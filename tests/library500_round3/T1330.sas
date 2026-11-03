/* T1330 sql_not_in_missing, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/proc_logistic_with_small_cohort_prunning2overfitting.sas:28 */

data t1330a; do x=1 to 11; output; end; x=.; output; run;
proc sql; create table t1330o as select sum(x) as actual from t1330a where x not in (.,11); quit;

data _null_; if 0 then set t1330o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1330 rows=' rows;
else do; set t1330o; if not missing(actual) and abs(actual-(55))<=1e-10*max(1,abs(55)) then put 'ROUND3_PASS=T1330';
else put 'ERROR: ROUND3_FAIL=T1330 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1330:; quit;
