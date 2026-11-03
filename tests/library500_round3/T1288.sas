/* T1288 sql_view_reexecute, N=9; source: SAS-Useful-Codes/Macros/SAS-macros-master/plotit.sas:4004 */

data t1288a; do x=1 to 9; output; end; run;
proc sql; create view t1288v as select * from t1288a; quit;
data t1288a; do x=1 to 2*9; output; end; run;
proc sql; create table t1288o as select count(*) as actual from t1288v; drop view t1288v; quit;

data _null_; if 0 then set t1288o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1288 rows=' rows;
else do; set t1288o; if not missing(actual) and abs(actual-(18))<=1e-10*max(1,abs(18)) then put 'ROUND3_PASS=T1288';
else put 'ERROR: ROUND3_FAIL=T1288 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1288:; quit;
