/* T1296 datastep_view_lazy, N=7; source: SAS-Useful-Codes/Macros/MacroNotUsed/K-means gap analysis.sas:54 */

data t1296a; do x=1 to 7; output; end; run;
data t1296v / view=t1296v; set t1296a; value=2*x; run;
data t1296a; do x=1 to 8; output; end; run;
proc sql; create table t1296o as select sum(value) as actual from t1296v; drop view t1296v; quit;

data _null_; if 0 then set t1296o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1296 rows=' rows;
else do; set t1296o; if not missing(actual) and abs(actual-(72))<=1e-10*max(1,abs(72)) then put 'ROUND3_PASS=T1296';
else put 'ERROR: ROUND3_FAIL=T1296 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1296:; quit;
