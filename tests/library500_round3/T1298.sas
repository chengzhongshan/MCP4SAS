/* T1298 datastep_view_lazy, N=9; source: SAS-Useful-Codes/Macros/MacroNotUsed/K-means gap analysis.sas:54 */

data t1298a; do x=1 to 9; output; end; run;
data t1298v / view=t1298v; set t1298a; value=2*x; run;
data t1298a; do x=1 to 10; output; end; run;
proc sql; create table t1298o as select sum(value) as actual from t1298v; drop view t1298v; quit;

data _null_; if 0 then set t1298o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1298 rows=' rows;
else do; set t1298o; if not missing(actual) and abs(actual-(110))<=1e-10*max(1,abs(110)) then put 'ROUND3_PASS=T1298';
else put 'ERROR: ROUND3_FAIL=T1298 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1298:; quit;
