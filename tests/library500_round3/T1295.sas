/* T1295 datastep_view_lazy, N=6; source: SAS-Useful-Codes/Macros/MacroNotUsed/K-means gap analysis.sas:54 */

data t1295a; do x=1 to 6; output; end; run;
data t1295v / view=t1295v; set t1295a; value=2*x; run;
data t1295a; do x=1 to 7; output; end; run;
proc sql; create table t1295o as select sum(value) as actual from t1295v; drop view t1295v; quit;

data _null_; if 0 then set t1295o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1295 rows=' rows;
else do; set t1295o; if not missing(actual) and abs(actual-(56))<=1e-10*max(1,abs(56)) then put 'ROUND3_PASS=T1295';
else put 'ERROR: ROUND3_FAIL=T1295 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1295:; quit;
