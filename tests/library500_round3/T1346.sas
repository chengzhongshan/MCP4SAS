/* T1346 sql_outobs_window, N=7; source: SAS-Useful-Codes/Macros/base4sas_developer/mp_assertcolvals.sas:124 */

data t1346a; do x=1 to 2*7; output; end; run;
proc sql outobs=7; create table t1346b as select * from t1346a order by x desc; quit;
proc sql; create table t1346o as select sum(x) as actual from t1346b; quit;

data _null_; if 0 then set t1346o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1346 rows=' rows;
else do; set t1346o; if not missing(actual) and abs(actual-(77))<=1e-10*max(1,abs(77)) then put 'ROUND3_PASS=T1346';
else put 'ERROR: ROUND3_FAIL=T1346 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1346:; quit;
