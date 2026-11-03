/* T1291 datastep_view_lazy, N=2; source: SAS-Useful-Codes/Macros/MacroNotUsed/K-means gap analysis.sas:54 */

data t1291a; do x=1 to 2; output; end; run;
data t1291v / view=t1291v; set t1291a; value=2*x; run;
data t1291a; do x=1 to 3; output; end; run;
proc sql; create table t1291o as select sum(value) as actual from t1291v; drop view t1291v; quit;

data _null_; if 0 then set t1291o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1291 rows=' rows;
else do; set t1291o; if not missing(actual) and abs(actual-(12))<=1e-10*max(1,abs(12)) then put 'ROUND3_PASS=T1291';
else put 'ERROR: ROUND3_FAIL=T1291 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1291:; quit;
