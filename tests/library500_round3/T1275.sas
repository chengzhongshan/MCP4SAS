/* T1275 outer_union_corr, N=6; source: SAS-Useful-Codes/Macros/MultiTranspose.sas:307 */

data t1275a; do x=1 to 6; output; end; run;
data t1275b; do y=1 to 6; output; end; run;
proc sql; create table t1275c as select x from t1275a outer union corr select y from t1275b;
create table t1275o as select sum(x)+sum(y) as actual from t1275c; quit;

data _null_; if 0 then set t1275o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1275 rows=' rows;
else do; set t1275o; if not missing(actual) and abs(actual-(42))<=1e-10*max(1,abs(42)) then put 'ROUND3_PASS=T1275';
else put 'ERROR: ROUND3_FAIL=T1275 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1275:; quit;
