/* T1326 sql_not_in_missing, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/proc_logistic_with_small_cohort_prunning2overfitting.sas:28 */

data t1326a; do x=1 to 7; output; end; x=.; output; run;
proc sql; create table t1326o as select sum(x) as actual from t1326a where x not in (.,7); quit;

data _null_; if 0 then set t1326o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1326 rows=' rows;
else do; set t1326o; if not missing(actual) and abs(actual-(21))<=1e-10*max(1,abs(21)) then put 'ROUND3_PASS=T1326';
else put 'ERROR: ROUND3_FAIL=T1326 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1326:; quit;
