/* T1348 sql_outobs_window, N=9; source: SAS-Useful-Codes/Macros/base4sas_developer/mp_assertcolvals.sas:124 */

data t1348a; do x=1 to 2*9; output; end; run;
proc sql outobs=9; create table t1348b as select * from t1348a order by x desc; quit;
proc sql; create table t1348o as select sum(x) as actual from t1348b; quit;

data _null_; if 0 then set t1348o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1348 rows=' rows;
else do; set t1348o; if not missing(actual) and abs(actual-(126))<=1e-10*max(1,abs(126)) then put 'ROUND3_PASS=T1348';
else put 'ERROR: ROUND3_FAIL=T1348 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1348:; quit;
