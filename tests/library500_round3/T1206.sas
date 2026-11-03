/* T1206 where_before_iteration, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:20 */

data t1206a; do x=1 to 2*7; output; end; run;
data t1206b; set t1206a(where=(mod(x,2)=0)); if _n_=1; run;
data t1206c; set t1206a; if mod(x,2)=0 and _n_=1; run;
proc sql; create table t1206d as select sum(x) as subtotal from t1206b;
create table t1206e as select count(*) as subtotal from t1206c;
create table t1206o as select b.subtotal+c.subtotal as actual from t1206d b,t1206e c; quit;

data _null_; if 0 then set t1206o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1206 rows=' rows;
else do; set t1206o; if not missing(actual) and abs(actual-(2))<=1e-10*max(1,abs(2)) then put 'ROUND3_PASS=T1206';
else put 'ERROR: ROUND3_FAIL=T1206 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1206:; quit;
