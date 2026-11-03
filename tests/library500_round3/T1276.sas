/* T1276 outer_union_corr, N=7; source: SAS-Useful-Codes/Macros/MultiTranspose.sas:307 */

data t1276a; do x=1 to 7; output; end; run;
data t1276b; do y=1 to 7; output; end; run;
proc sql; create table t1276c as select x from t1276a outer union corr select y from t1276b;
create table t1276o as select sum(x)+sum(y) as actual from t1276c; quit;

data _null_; if 0 then set t1276o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1276 rows=' rows;
else do; set t1276o; if not missing(actual) and abs(actual-(56))<=1e-10*max(1,abs(56)) then put 'ROUND3_PASS=T1276';
else put 'ERROR: ROUND3_FAIL=T1276 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1276:; quit;
