/* T1274 outer_union_corr, N=5; source: SAS-Useful-Codes/Macros/MultiTranspose.sas:307 */

data t1274a; do x=1 to 5; output; end; run;
data t1274b; do y=1 to 5; output; end; run;
proc sql; create table t1274c as select x from t1274a outer union corr select y from t1274b;
create table t1274o as select sum(x)+sum(y) as actual from t1274c; quit;

data _null_; if 0 then set t1274o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1274 rows=' rows;
else do; set t1274o; if not missing(actual) and abs(actual-(30))<=1e-10*max(1,abs(30)) then put 'ROUND3_PASS=T1274';
else put 'ERROR: ROUND3_FAIL=T1274 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1274:; quit;
