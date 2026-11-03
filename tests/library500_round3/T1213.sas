/* T1213 firstobs_obs_window, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:22 */

data t1213a; do x=1 to 2*4+2; output; end; run;
data t1213b; set t1213a(firstobs=4 obs=6); run;
proc sql; create table t1213o as select sum(x) as actual from t1213b; quit;

data _null_; if 0 then set t1213o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1213 rows=' rows;
else do; set t1213o; if not missing(actual) and abs(actual-(15))<=1e-10*max(1,abs(15)) then put 'ROUND3_PASS=T1213';
else put 'ERROR: ROUND3_FAIL=T1213 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1213:; quit;
