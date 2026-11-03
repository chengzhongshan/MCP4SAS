/* T1344 sql_outobs_window, N=5; source: SAS-Useful-Codes/Macros/base4sas_developer/mp_assertcolvals.sas:124 */

data t1344a; do x=1 to 2*5; output; end; run;
proc sql outobs=5; create table t1344b as select * from t1344a order by x desc; quit;
proc sql; create table t1344o as select sum(x) as actual from t1344b; quit;

data _null_; if 0 then set t1344o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1344 rows=' rows;
else do; set t1344o; if not missing(actual) and abs(actual-(40))<=1e-10*max(1,abs(40)) then put 'ROUND3_PASS=T1344';
else put 'ERROR: ROUND3_FAIL=T1344 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1344:; quit;
