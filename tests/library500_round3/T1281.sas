/* T1281 sql_view_reexecute, N=2; source: SAS-Useful-Codes/Macros/SAS-macros-master/plotit.sas:4004 */

data t1281a; do x=1 to 2; output; end; run;
proc sql; create view t1281v as select * from t1281a; quit;
data t1281a; do x=1 to 2*2; output; end; run;
proc sql; create table t1281o as select count(*) as actual from t1281v; drop view t1281v; quit;

data _null_; if 0 then set t1281o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1281 rows=' rows;
else do; set t1281o; if not missing(actual) and abs(actual-(4))<=1e-10*max(1,abs(4)) then put 'ROUND3_PASS=T1281';
else put 'ERROR: ROUND3_FAIL=T1281 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1281:; quit;
