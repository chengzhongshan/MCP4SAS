/* T1212 firstobs_obs_window, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:22 */

data t1212a; do x=1 to 2*3+2; output; end; run;
data t1212b; set t1212a(firstobs=3 obs=5); run;
proc sql; create table t1212o as select sum(x) as actual from t1212b; quit;

data _null_; if 0 then set t1212o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1212 rows=' rows;
else do; set t1212o; if not missing(actual) and abs(actual-(12))<=1e-10*max(1,abs(12)) then put 'ROUND3_PASS=T1212';
else put 'ERROR: ROUND3_FAIL=T1212 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1212:; quit;
