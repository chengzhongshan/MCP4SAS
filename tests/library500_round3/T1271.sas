/* T1271 outer_union_corr, N=2; source: SAS-Useful-Codes/Macros/MultiTranspose.sas:307 */

data t1271a; do x=1 to 2; output; end; run;
data t1271b; do y=1 to 2; output; end; run;
proc sql; create table t1271c as select x from t1271a outer union corr select y from t1271b;
create table t1271o as select sum(x)+sum(y) as actual from t1271c; quit;

data _null_; if 0 then set t1271o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1271 rows=' rows;
else do; set t1271o; if not missing(actual) and abs(actual-(6))<=1e-10*max(1,abs(6)) then put 'ROUND3_PASS=T1271';
else put 'ERROR: ROUND3_FAIL=T1271 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1271:; quit;
