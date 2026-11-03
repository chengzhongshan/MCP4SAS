/* T1345 sql_outobs_window, N=6; source: SAS-Useful-Codes/Macros/base4sas_developer/mp_assertcolvals.sas:124 */

data t1345a; do x=1 to 2*6; output; end; run;
proc sql outobs=6; create table t1345b as select * from t1345a order by x desc; quit;
proc sql; create table t1345o as select sum(x) as actual from t1345b; quit;

data _null_; if 0 then set t1345o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1345 rows=' rows;
else do; set t1345o; if not missing(actual) and abs(actual-(57))<=1e-10*max(1,abs(57)) then put 'ROUND3_PASS=T1345';
else put 'ERROR: ROUND3_FAIL=T1345 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1345:; quit;
