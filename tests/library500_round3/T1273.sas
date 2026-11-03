/* T1273 outer_union_corr, N=4; source: SAS-Useful-Codes/Macros/MultiTranspose.sas:307 */

data t1273a; do x=1 to 4; output; end; run;
data t1273b; do y=1 to 4; output; end; run;
proc sql; create table t1273c as select x from t1273a outer union corr select y from t1273b;
create table t1273o as select sum(x)+sum(y) as actual from t1273c; quit;

data _null_; if 0 then set t1273o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1273 rows=' rows;
else do; set t1273o; if not missing(actual) and abs(actual-(20))<=1e-10*max(1,abs(20)) then put 'ROUND3_PASS=T1273';
else put 'ERROR: ROUND3_FAIL=T1273 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1273:; quit;
