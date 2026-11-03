/* T1300 datastep_view_lazy, N=11; source: SAS-Useful-Codes/Macros/MacroNotUsed/K-means gap analysis.sas:54 */

data t1300a; do x=1 to 11; output; end; run;
data t1300v / view=t1300v; set t1300a; value=2*x; run;
data t1300a; do x=1 to 12; output; end; run;
proc sql; create table t1300o as select sum(value) as actual from t1300v; drop view t1300v; quit;

data _null_; if 0 then set t1300o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1300 rows=' rows;
else do; set t1300o; if not missing(actual) and abs(actual-(156))<=1e-10*max(1,abs(156)) then put 'ROUND3_PASS=T1300';
else put 'ERROR: ROUND3_FAIL=T1300 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1300:; quit;
