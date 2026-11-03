/* T1286 sql_view_reexecute, N=7; source: SAS-Useful-Codes/Macros/SAS-macros-master/plotit.sas:4004 */

data t1286a; do x=1 to 7; output; end; run;
proc sql; create view t1286v as select * from t1286a; quit;
data t1286a; do x=1 to 2*7; output; end; run;
proc sql; create table t1286o as select count(*) as actual from t1286v; drop view t1286v; quit;

data _null_; if 0 then set t1286o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1286 rows=' rows;
else do; set t1286o; if not missing(actual) and abs(actual-(14))<=1e-10*max(1,abs(14)) then put 'ROUND3_PASS=T1286';
else put 'ERROR: ROUND3_FAIL=T1286 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1286:; quit;
