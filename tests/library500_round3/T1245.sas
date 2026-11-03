/* T1245 freq_zero_weight, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/order_by_data_for_proc_freq_OR_calculation.sas:26 */

data t1245a; do grp=0 to 6; weight=grp; output; end; run;
proc freq data=t1245a noprint; tables grp / out=t1245b; weight weight / zeros; run;
proc sql; create table t1245o as select count(*) as actual from t1245b; quit;

data _null_; if 0 then set t1245o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1245 rows=' rows;
else do; set t1245o; if not missing(actual) and abs(actual-(7))<=1e-10*max(1,abs(7)) then put 'ROUND3_PASS=T1245';
else put 'ERROR: ROUND3_FAIL=T1245 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1245:; quit;
