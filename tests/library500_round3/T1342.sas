/* T1342 sql_outobs_window, N=3; source: SAS-Useful-Codes/Macros/base4sas_developer/mp_assertcolvals.sas:124 */

data t1342a; do x=1 to 2*3; output; end; run;
proc sql outobs=3; create table t1342b as select * from t1342a order by x desc; quit;
proc sql; create table t1342o as select sum(x) as actual from t1342b; quit;

data _null_; if 0 then set t1342o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1342 rows=' rows;
else do; set t1342o; if not missing(actual) and abs(actual-(15))<=1e-10*max(1,abs(15)) then put 'ROUND3_PASS=T1342';
else put 'ERROR: ROUND3_FAIL=T1342 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1342:; quit;
