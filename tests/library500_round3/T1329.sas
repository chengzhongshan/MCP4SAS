/* T1329 sql_not_in_missing, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/proc_logistic_with_small_cohort_prunning2overfitting.sas:28 */

data t1329a; do x=1 to 10; output; end; x=.; output; run;
proc sql; create table t1329o as select sum(x) as actual from t1329a where x not in (.,10); quit;

data _null_; if 0 then set t1329o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1329 rows=' rows;
else do; set t1329o; if not missing(actual) and abs(actual-(45))<=1e-10*max(1,abs(45)) then put 'ROUND3_PASS=T1329';
else put 'ERROR: ROUND3_FAIL=T1329 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1329:; quit;
