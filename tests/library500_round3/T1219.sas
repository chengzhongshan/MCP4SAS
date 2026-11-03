/* T1219 firstobs_obs_window, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:22 */

data t1219a; do x=1 to 2*10+2; output; end; run;
data t1219b; set t1219a(firstobs=10 obs=12); run;
proc sql; create table t1219o as select sum(x) as actual from t1219b; quit;

data _null_; if 0 then set t1219o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1219 rows=' rows;
else do; set t1219o; if not missing(actual) and abs(actual-(33))<=1e-10*max(1,abs(33)) then put 'ROUND3_PASS=T1219';
else put 'ERROR: ROUND3_FAIL=T1219 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1219:; quit;
