/* T1282 sql_view_reexecute, N=3; source: SAS-Useful-Codes/Macros/SAS-macros-master/plotit.sas:4004 */

data t1282a; do x=1 to 3; output; end; run;
proc sql; create view t1282v as select * from t1282a; quit;
data t1282a; do x=1 to 2*3; output; end; run;
proc sql; create table t1282o as select count(*) as actual from t1282v; drop view t1282v; quit;

data _null_; if 0 then set t1282o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1282 rows=' rows;
else do; set t1282o; if not missing(actual) and abs(actual-(6))<=1e-10*max(1,abs(6)) then put 'ROUND3_PASS=T1282';
else put 'ERROR: ROUND3_FAIL=T1282 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1282:; quit;
