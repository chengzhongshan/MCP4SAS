/* T1203 where_before_iteration, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:20 */

data t1203a; do x=1 to 2*4; output; end; run;
data t1203b; set t1203a(where=(mod(x,2)=0)); if _n_=1; run;
data t1203c; set t1203a; if mod(x,2)=0 and _n_=1; run;
proc sql; create table t1203d as select sum(x) as subtotal from t1203b;
create table t1203e as select count(*) as subtotal from t1203c;
create table t1203o as select b.subtotal+c.subtotal as actual from t1203d b,t1203e c; quit;

data _null_; if 0 then set t1203o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1203 rows=' rows;
else do; set t1203o; if not missing(actual) and abs(actual-(2))<=1e-10*max(1,abs(2)) then put 'ROUND3_PASS=T1203';
else put 'ERROR: ROUND3_FAIL=T1203 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1203:; quit;
