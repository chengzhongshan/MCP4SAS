/* T1204 where_before_iteration, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:20 */

data t1204a; do x=1 to 2*5; output; end; run;
data t1204b; set t1204a(where=(mod(x,2)=0)); if _n_=1; run;
data t1204c; set t1204a; if mod(x,2)=0 and _n_=1; run;
proc sql; create table t1204d as select sum(x) as subtotal from t1204b;
create table t1204e as select count(*) as subtotal from t1204c;
create table t1204o as select b.subtotal+c.subtotal as actual from t1204d b,t1204e c; quit;

data _null_; if 0 then set t1204o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1204 rows=' rows;
else do; set t1204o; if not missing(actual) and abs(actual-(2))<=1e-10*max(1,abs(2)) then put 'ROUND3_PASS=T1204';
else put 'ERROR: ROUND3_FAIL=T1204 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1204:; quit;
