/* T1210 where_before_iteration, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:20 */

data t1210a; do x=1 to 2*11; output; end; run;
data t1210b; set t1210a(where=(mod(x,2)=0)); if _n_=1; run;
data t1210c; set t1210a; if mod(x,2)=0 and _n_=1; run;
proc sql; create table t1210d as select sum(x) as subtotal from t1210b;
create table t1210e as select count(*) as subtotal from t1210c;
create table t1210o as select b.subtotal+c.subtotal as actual from t1210d b,t1210e c; quit;

data _null_; if 0 then set t1210o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1210 rows=' rows;
else do; set t1210o; if not missing(actual) and abs(actual-(2))<=1e-10*max(1,abs(2)) then put 'ROUND3_PASS=T1210';
else put 'ERROR: ROUND3_FAIL=T1210 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1210:; quit;
