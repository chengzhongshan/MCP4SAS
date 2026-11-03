/* T1343 sql_outobs_window, N=4; source: SAS-Useful-Codes/Macros/base4sas_developer/mp_assertcolvals.sas:124 */

data t1343a; do x=1 to 2*4; output; end; run;
proc sql outobs=4; create table t1343b as select * from t1343a order by x desc; quit;
proc sql; create table t1343o as select sum(x) as actual from t1343b; quit;

data _null_; if 0 then set t1343o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1343 rows=' rows;
else do; set t1343o; if not missing(actual) and abs(actual-(26))<=1e-10*max(1,abs(26)) then put 'ROUND3_PASS=T1343';
else put 'ERROR: ROUND3_FAIL=T1343 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1343:; quit;
