/* T1211 firstobs_obs_window, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:22 */

data t1211a; do x=1 to 2*2+2; output; end; run;
data t1211b; set t1211a(firstobs=2 obs=4); run;
proc sql; create table t1211o as select sum(x) as actual from t1211b; quit;

data _null_; if 0 then set t1211o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1211 rows=' rows;
else do; set t1211o; if not missing(actual) and abs(actual-(9))<=1e-10*max(1,abs(9)) then put 'ROUND3_PASS=T1211';
else put 'ERROR: ROUND3_FAIL=T1211 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1211:; quit;
