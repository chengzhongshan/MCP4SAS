/* T1272 outer_union_corr, N=3; source: SAS-Useful-Codes/Macros/MultiTranspose.sas:307 */

data t1272a; do x=1 to 3; output; end; run;
data t1272b; do y=1 to 3; output; end; run;
proc sql; create table t1272c as select x from t1272a outer union corr select y from t1272b;
create table t1272o as select sum(x)+sum(y) as actual from t1272c; quit;

data _null_; if 0 then set t1272o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1272 rows=' rows;
else do; set t1272o; if not missing(actual) and abs(actual-(12))<=1e-10*max(1,abs(12)) then put 'ROUND3_PASS=T1272';
else put 'ERROR: ROUND3_FAIL=T1272 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1272:; quit;
