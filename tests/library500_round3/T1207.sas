/* T1207 where_before_iteration, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:20 */

data t1207a; do x=1 to 2*8; output; end; run;
data t1207b; set t1207a(where=(mod(x,2)=0)); if _n_=1; run;
data t1207c; set t1207a; if mod(x,2)=0 and _n_=1; run;
proc sql; create table t1207d as select sum(x) as subtotal from t1207b;
create table t1207e as select count(*) as subtotal from t1207c;
create table t1207o as select b.subtotal+c.subtotal as actual from t1207d b,t1207e c; quit;

data _null_; if 0 then set t1207o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1207 rows=' rows;
else do; set t1207o; if not missing(actual) and abs(actual-(2))<=1e-10*max(1,abs(2)) then put 'ROUND3_PASS=T1207';
else put 'ERROR: ROUND3_FAIL=T1207 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1207:; quit;
