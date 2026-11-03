/* T1242 freq_zero_weight, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/order_by_data_for_proc_freq_OR_calculation.sas:26 */

data t1242a; do grp=0 to 3; weight=grp; output; end; run;
proc freq data=t1242a noprint; tables grp / out=t1242b; weight weight / zeros; run;
proc sql; create table t1242o as select count(*) as actual from t1242b; quit;

data _null_; if 0 then set t1242o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1242 rows=' rows;
else do; set t1242o; if not missing(actual) and abs(actual-(4))<=1e-10*max(1,abs(4)) then put 'ROUND3_PASS=T1242';
else put 'ERROR: ROUND3_FAIL=T1242 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1242:; quit;
