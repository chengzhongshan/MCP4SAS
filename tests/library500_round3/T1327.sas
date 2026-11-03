/* T1327 sql_not_in_missing, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/proc_logistic_with_small_cohort_prunning2overfitting.sas:28 */

data t1327a; do x=1 to 8; output; end; x=.; output; run;
proc sql; create table t1327o as select sum(x) as actual from t1327a where x not in (.,8); quit;

data _null_; if 0 then set t1327o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1327 rows=' rows;
else do; set t1327o; if not missing(actual) and abs(actual-(28))<=1e-10*max(1,abs(28)) then put 'ROUND3_PASS=T1327';
else put 'ERROR: ROUND3_FAIL=T1327 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1327:; quit;
