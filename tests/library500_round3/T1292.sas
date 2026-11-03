/* T1292 datastep_view_lazy, N=3; source: SAS-Useful-Codes/Macros/MacroNotUsed/K-means gap analysis.sas:54 */

data t1292a; do x=1 to 3; output; end; run;
data t1292v / view=t1292v; set t1292a; value=2*x; run;
data t1292a; do x=1 to 4; output; end; run;
proc sql; create table t1292o as select sum(value) as actual from t1292v; drop view t1292v; quit;

data _null_; if 0 then set t1292o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1292 rows=' rows;
else do; set t1292o; if not missing(actual) and abs(actual-(20))<=1e-10*max(1,abs(20)) then put 'ROUND3_PASS=T1292';
else put 'ERROR: ROUND3_FAIL=T1292 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1292:; quit;
