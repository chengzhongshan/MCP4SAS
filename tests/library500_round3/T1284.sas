/* T1284 sql_view_reexecute, N=5; source: SAS-Useful-Codes/Macros/SAS-macros-master/plotit.sas:4004 */

data t1284a; do x=1 to 5; output; end; run;
proc sql; create view t1284v as select * from t1284a; quit;
data t1284a; do x=1 to 2*5; output; end; run;
proc sql; create table t1284o as select count(*) as actual from t1284v; drop view t1284v; quit;

data _null_; if 0 then set t1284o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1284 rows=' rows;
else do; set t1284o; if not missing(actual) and abs(actual-(10))<=1e-10*max(1,abs(10)) then put 'ROUND3_PASS=T1284';
else put 'ERROR: ROUND3_FAIL=T1284 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1284:; quit;
