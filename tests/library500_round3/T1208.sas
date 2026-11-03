/* T1208 where_before_iteration, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:20 */

data t1208a; do x=1 to 2*9; output; end; run;
data t1208b; set t1208a(where=(mod(x,2)=0)); if _n_=1; run;
data t1208c; set t1208a; if mod(x,2)=0 and _n_=1; run;
proc sql; create table t1208d as select sum(x) as subtotal from t1208b;
create table t1208e as select count(*) as subtotal from t1208c;
create table t1208o as select b.subtotal+c.subtotal as actual from t1208d b,t1208e c; quit;

data _null_; if 0 then set t1208o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1208 rows=' rows;
else do; set t1208o; if not missing(actual) and abs(actual-(2))<=1e-10*max(1,abs(2)) then put 'ROUND3_PASS=T1208';
else put 'ERROR: ROUND3_FAIL=T1208 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1208:; quit;
