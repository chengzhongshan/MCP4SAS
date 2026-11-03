/* T1214 firstobs_obs_window, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:22 */

data t1214a; do x=1 to 2*5+2; output; end; run;
data t1214b; set t1214a(firstobs=5 obs=7); run;
proc sql; create table t1214o as select sum(x) as actual from t1214b; quit;

data _null_; if 0 then set t1214o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1214 rows=' rows;
else do; set t1214o; if not missing(actual) and abs(actual-(18))<=1e-10*max(1,abs(18)) then put 'ROUND3_PASS=T1214';
else put 'ERROR: ROUND3_FAIL=T1214 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1214:; quit;
