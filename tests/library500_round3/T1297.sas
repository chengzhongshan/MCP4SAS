/* T1297 datastep_view_lazy, N=8; source: SAS-Useful-Codes/Macros/MacroNotUsed/K-means gap analysis.sas:54 */

data t1297a; do x=1 to 8; output; end; run;
data t1297v / view=t1297v; set t1297a; value=2*x; run;
data t1297a; do x=1 to 9; output; end; run;
proc sql; create table t1297o as select sum(value) as actual from t1297v; drop view t1297v; quit;

data _null_; if 0 then set t1297o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1297 rows=' rows;
else do; set t1297o; if not missing(actual) and abs(actual-(90))<=1e-10*max(1,abs(90)) then put 'ROUND3_PASS=T1297';
else put 'ERROR: ROUND3_FAIL=T1297 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1297:; quit;
