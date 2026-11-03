/* T1347 sql_outobs_window, N=8; source: SAS-Useful-Codes/Macros/base4sas_developer/mp_assertcolvals.sas:124 */

data t1347a; do x=1 to 2*8; output; end; run;
proc sql outobs=8; create table t1347b as select * from t1347a order by x desc; quit;
proc sql; create table t1347o as select sum(x) as actual from t1347b; quit;

data _null_; if 0 then set t1347o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1347 rows=' rows;
else do; set t1347o; if not missing(actual) and abs(actual-(100))<=1e-10*max(1,abs(100)) then put 'ROUND3_PASS=T1347';
else put 'ERROR: ROUND3_FAIL=T1347 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1347:; quit;
