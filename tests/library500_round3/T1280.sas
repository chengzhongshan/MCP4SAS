/* T1280 outer_union_corr, N=11; source: SAS-Useful-Codes/Macros/MultiTranspose.sas:307 */

data t1280a; do x=1 to 11; output; end; run;
data t1280b; do y=1 to 11; output; end; run;
proc sql; create table t1280c as select x from t1280a outer union corr select y from t1280b;
create table t1280o as select sum(x)+sum(y) as actual from t1280c; quit;

data _null_; if 0 then set t1280o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1280 rows=' rows;
else do; set t1280o; if not missing(actual) and abs(actual-(132))<=1e-10*max(1,abs(132)) then put 'ROUND3_PASS=T1280';
else put 'ERROR: ROUND3_FAIL=T1280 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1280:; quit;
