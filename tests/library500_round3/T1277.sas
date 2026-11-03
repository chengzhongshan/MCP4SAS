/* T1277 outer_union_corr, N=8; source: SAS-Useful-Codes/Macros/MultiTranspose.sas:307 */

data t1277a; do x=1 to 8; output; end; run;
data t1277b; do y=1 to 8; output; end; run;
proc sql; create table t1277c as select x from t1277a outer union corr select y from t1277b;
create table t1277o as select sum(x)+sum(y) as actual from t1277c; quit;

data _null_; if 0 then set t1277o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1277 rows=' rows;
else do; set t1277o; if not missing(actual) and abs(actual-(72))<=1e-10*max(1,abs(72)) then put 'ROUND3_PASS=T1277';
else put 'ERROR: ROUND3_FAIL=T1277 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1277:; quit;
