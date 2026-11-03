/* T1215 firstobs_obs_window, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:22 */

data t1215a; do x=1 to 2*6+2; output; end; run;
data t1215b; set t1215a(firstobs=6 obs=8); run;
proc sql; create table t1215o as select sum(x) as actual from t1215b; quit;

data _null_; if 0 then set t1215o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1215 rows=' rows;
else do; set t1215o; if not missing(actual) and abs(actual-(21))<=1e-10*max(1,abs(21)) then put 'ROUND3_PASS=T1215';
else put 'ERROR: ROUND3_FAIL=T1215 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1215:; quit;
