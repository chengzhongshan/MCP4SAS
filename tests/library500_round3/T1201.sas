/* T1201 where_before_iteration, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:20 */

data t1201a; do x=1 to 2*2; output; end; run;
data t1201b; set t1201a(where=(mod(x,2)=0)); if _n_=1; run;
data t1201c; set t1201a; if mod(x,2)=0 and _n_=1; run;
proc sql; create table t1201d as select sum(x) as subtotal from t1201b;
create table t1201e as select count(*) as subtotal from t1201c;
create table t1201o as select b.subtotal+c.subtotal as actual from t1201d b,t1201e c; quit;

data _null_; if 0 then set t1201o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1201 rows=' rows;
else do; set t1201o; if not missing(actual) and abs(actual-(2))<=1e-10*max(1,abs(2)) then put 'ROUND3_PASS=T1201';
else put 'ERROR: ROUND3_FAIL=T1201 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1201:; quit;
