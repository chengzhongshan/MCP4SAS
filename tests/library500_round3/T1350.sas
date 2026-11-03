/* T1350 sql_outobs_window, N=11; source: SAS-Useful-Codes/Macros/base4sas_developer/mp_assertcolvals.sas:124 */

data t1350a; do x=1 to 2*11; output; end; run;
proc sql outobs=11; create table t1350b as select * from t1350a order by x desc; quit;
proc sql; create table t1350o as select sum(x) as actual from t1350b; quit;

data _null_; if 0 then set t1350o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1350 rows=' rows;
else do; set t1350o; if not missing(actual) and abs(actual-(187))<=1e-10*max(1,abs(187)) then put 'ROUND3_PASS=T1350';
else put 'ERROR: ROUND3_FAIL=T1350 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1350:; quit;
