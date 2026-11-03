/* T1349 sql_outobs_window, N=10; source: SAS-Useful-Codes/Macros/base4sas_developer/mp_assertcolvals.sas:124 */

data t1349a; do x=1 to 2*10; output; end; run;
proc sql outobs=10; create table t1349b as select * from t1349a order by x desc; quit;
proc sql; create table t1349o as select sum(x) as actual from t1349b; quit;

data _null_; if 0 then set t1349o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1349 rows=' rows;
else do; set t1349o; if not missing(actual) and abs(actual-(155))<=1e-10*max(1,abs(155)) then put 'ROUND3_PASS=T1349';
else put 'ERROR: ROUND3_FAIL=T1349 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1349:; quit;
