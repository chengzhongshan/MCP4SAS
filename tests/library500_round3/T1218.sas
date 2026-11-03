/* T1218 firstobs_obs_window, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:22 */

data t1218a; do x=1 to 2*9+2; output; end; run;
data t1218b; set t1218a(firstobs=9 obs=11); run;
proc sql; create table t1218o as select sum(x) as actual from t1218b; quit;

data _null_; if 0 then set t1218o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1218 rows=' rows;
else do; set t1218o; if not missing(actual) and abs(actual-(30))<=1e-10*max(1,abs(30)) then put 'ROUND3_PASS=T1218';
else put 'ERROR: ROUND3_FAIL=T1218 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1218:; quit;
