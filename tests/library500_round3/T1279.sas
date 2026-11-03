/* T1279 outer_union_corr, N=10; source: SAS-Useful-Codes/Macros/MultiTranspose.sas:307 */

data t1279a; do x=1 to 10; output; end; run;
data t1279b; do y=1 to 10; output; end; run;
proc sql; create table t1279c as select x from t1279a outer union corr select y from t1279b;
create table t1279o as select sum(x)+sum(y) as actual from t1279c; quit;

data _null_; if 0 then set t1279o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1279 rows=' rows;
else do; set t1279o; if not missing(actual) and abs(actual-(110))<=1e-10*max(1,abs(110)) then put 'ROUND3_PASS=T1279';
else put 'ERROR: ROUND3_FAIL=T1279 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1279:; quit;
