/* T1250 freq_zero_weight, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/order_by_data_for_proc_freq_OR_calculation.sas:26 */

data t1250a; do grp=0 to 11; weight=grp; output; end; run;
proc freq data=t1250a noprint; tables grp / out=t1250b; weight weight / zeros; run;
proc sql; create table t1250o as select count(*) as actual from t1250b; quit;

data _null_; if 0 then set t1250o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1250 rows=' rows;
else do; set t1250o; if not missing(actual) and abs(actual-(12))<=1e-10*max(1,abs(12)) then put 'ROUND3_PASS=T1250';
else put 'ERROR: ROUND3_FAIL=T1250 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1250:; quit;
