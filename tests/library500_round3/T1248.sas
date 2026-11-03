/* T1248 freq_zero_weight, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/order_by_data_for_proc_freq_OR_calculation.sas:26 */

data t1248a; do grp=0 to 9; weight=grp; output; end; run;
proc freq data=t1248a noprint; tables grp / out=t1248b; weight weight / zeros; run;
proc sql; create table t1248o as select count(*) as actual from t1248b; quit;

data _null_; if 0 then set t1248o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1248 rows=' rows;
else do; set t1248o; if not missing(actual) and abs(actual-(10))<=1e-10*max(1,abs(10)) then put 'ROUND3_PASS=T1248';
else put 'ERROR: ROUND3_FAIL=T1248 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1248:; quit;
