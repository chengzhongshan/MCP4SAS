/* T1299 datastep_view_lazy, N=10; source: SAS-Useful-Codes/Macros/MacroNotUsed/K-means gap analysis.sas:54 */

data t1299a; do x=1 to 10; output; end; run;
data t1299v / view=t1299v; set t1299a; value=2*x; run;
data t1299a; do x=1 to 11; output; end; run;
proc sql; create table t1299o as select sum(value) as actual from t1299v; drop view t1299v; quit;

data _null_; if 0 then set t1299o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1299 rows=' rows;
else do; set t1299o; if not missing(actual) and abs(actual-(132))<=1e-10*max(1,abs(132)) then put 'ROUND3_PASS=T1299';
else put 'ERROR: ROUND3_FAIL=T1299 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1299:; quit;
