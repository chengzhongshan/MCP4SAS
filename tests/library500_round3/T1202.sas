/* T1202 where_before_iteration, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:20 */

data t1202a; do x=1 to 2*3; output; end; run;
data t1202b; set t1202a(where=(mod(x,2)=0)); if _n_=1; run;
data t1202c; set t1202a; if mod(x,2)=0 and _n_=1; run;
proc sql; create table t1202d as select sum(x) as subtotal from t1202b;
create table t1202e as select count(*) as subtotal from t1202c;
create table t1202o as select b.subtotal+c.subtotal as actual from t1202d b,t1202e c; quit;

data _null_; if 0 then set t1202o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1202 rows=' rows;
else do; set t1202o; if not missing(actual) and abs(actual-(2))<=1e-10*max(1,abs(2)) then put 'ROUND3_PASS=T1202';
else put 'ERROR: ROUND3_FAIL=T1202 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1202:; quit;
