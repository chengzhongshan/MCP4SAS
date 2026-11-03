/* T1341 sql_outobs_window, N=2; source: SAS-Useful-Codes/Macros/base4sas_developer/mp_assertcolvals.sas:124 */

data t1341a; do x=1 to 2*2; output; end; run;
proc sql outobs=2; create table t1341b as select * from t1341a order by x desc; quit;
proc sql; create table t1341o as select sum(x) as actual from t1341b; quit;

data _null_; if 0 then set t1341o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1341 rows=' rows;
else do; set t1341o; if not missing(actual) and abs(actual-(7))<=1e-10*max(1,abs(7)) then put 'ROUND3_PASS=T1341';
else put 'ERROR: ROUND3_FAIL=T1341 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1341:; quit;
