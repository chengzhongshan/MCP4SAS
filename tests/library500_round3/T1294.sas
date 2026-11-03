/* T1294 datastep_view_lazy, N=5; source: SAS-Useful-Codes/Macros/MacroNotUsed/K-means gap analysis.sas:54 */

data t1294a; do x=1 to 5; output; end; run;
data t1294v / view=t1294v; set t1294a; value=2*x; run;
data t1294a; do x=1 to 6; output; end; run;
proc sql; create table t1294o as select sum(value) as actual from t1294v; drop view t1294v; quit;

data _null_; if 0 then set t1294o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1294 rows=' rows;
else do; set t1294o; if not missing(actual) and abs(actual-(42))<=1e-10*max(1,abs(42)) then put 'ROUND3_PASS=T1294';
else put 'ERROR: ROUND3_FAIL=T1294 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1294:; quit;
