/* T1220 firstobs_obs_window, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:22 */

data t1220a; do x=1 to 2*11+2; output; end; run;
data t1220b; set t1220a(firstobs=11 obs=13); run;
proc sql; create table t1220o as select sum(x) as actual from t1220b; quit;

data _null_; if 0 then set t1220o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1220 rows=' rows;
else do; set t1220o; if not missing(actual) and abs(actual-(36))<=1e-10*max(1,abs(36)) then put 'ROUND3_PASS=T1220';
else put 'ERROR: ROUND3_FAIL=T1220 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1220:; quit;
