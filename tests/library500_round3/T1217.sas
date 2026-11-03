/* T1217 firstobs_obs_window, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:22 */

data t1217a; do x=1 to 2*8+2; output; end; run;
data t1217b; set t1217a(firstobs=8 obs=10); run;
proc sql; create table t1217o as select sum(x) as actual from t1217b; quit;

data _null_; if 0 then set t1217o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1217 rows=' rows;
else do; set t1217o; if not missing(actual) and abs(actual-(27))<=1e-10*max(1,abs(27)) then put 'ROUND3_PASS=T1217';
else put 'ERROR: ROUND3_FAIL=T1217 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1217:; quit;
