/* T1293 datastep_view_lazy, N=4; source: SAS-Useful-Codes/Macros/MacroNotUsed/K-means gap analysis.sas:54 */

data t1293a; do x=1 to 4; output; end; run;
data t1293v / view=t1293v; set t1293a; value=2*x; run;
data t1293a; do x=1 to 5; output; end; run;
proc sql; create table t1293o as select sum(value) as actual from t1293v; drop view t1293v; quit;

data _null_; if 0 then set t1293o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1293 rows=' rows;
else do; set t1293o; if not missing(actual) and abs(actual-(30))<=1e-10*max(1,abs(30)) then put 'ROUND3_PASS=T1293';
else put 'ERROR: ROUND3_FAIL=T1293 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1293:; quit;
