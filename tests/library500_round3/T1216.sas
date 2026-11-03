/* T1216 firstobs_obs_window, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:22 */

data t1216a; do x=1 to 2*7+2; output; end; run;
data t1216b; set t1216a(firstobs=7 obs=9); run;
proc sql; create table t1216o as select sum(x) as actual from t1216b; quit;

data _null_; if 0 then set t1216o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1216 rows=' rows;
else do; set t1216o; if not missing(actual) and abs(actual-(24))<=1e-10*max(1,abs(24)) then put 'ROUND3_PASS=T1216';
else put 'ERROR: ROUND3_FAIL=T1216 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1216:; quit;
