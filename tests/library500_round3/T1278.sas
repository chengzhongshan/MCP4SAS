/* T1278 outer_union_corr, N=9; source: SAS-Useful-Codes/Macros/MultiTranspose.sas:307 */

data t1278a; do x=1 to 9; output; end; run;
data t1278b; do y=1 to 9; output; end; run;
proc sql; create table t1278c as select x from t1278a outer union corr select y from t1278b;
create table t1278o as select sum(x)+sum(y) as actual from t1278c; quit;

data _null_; if 0 then set t1278o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1278 rows=' rows;
else do; set t1278o; if not missing(actual) and abs(actual-(90))<=1e-10*max(1,abs(90)) then put 'ROUND3_PASS=T1278';
else put 'ERROR: ROUND3_FAIL=T1278 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1278:; quit;
