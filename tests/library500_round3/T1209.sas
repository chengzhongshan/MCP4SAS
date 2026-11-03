/* T1209 where_before_iteration, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:20 */

data t1209a; do x=1 to 2*10; output; end; run;
data t1209b; set t1209a(where=(mod(x,2)=0)); if _n_=1; run;
data t1209c; set t1209a; if mod(x,2)=0 and _n_=1; run;
proc sql; create table t1209d as select sum(x) as subtotal from t1209b;
create table t1209e as select count(*) as subtotal from t1209c;
create table t1209o as select b.subtotal+c.subtotal as actual from t1209d b,t1209e c; quit;

data _null_; if 0 then set t1209o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1209 rows=' rows;
else do; set t1209o; if not missing(actual) and abs(actual-(2))<=1e-10*max(1,abs(2)) then put 'ROUND3_PASS=T1209';
else put 'ERROR: ROUND3_FAIL=T1209 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1209:; quit;
