/* T1285 sql_view_reexecute, N=6; source: SAS-Useful-Codes/Macros/SAS-macros-master/plotit.sas:4004 */

data t1285a; do x=1 to 6; output; end; run;
proc sql; create view t1285v as select * from t1285a; quit;
data t1285a; do x=1 to 2*6; output; end; run;
proc sql; create table t1285o as select count(*) as actual from t1285v; drop view t1285v; quit;

data _null_; if 0 then set t1285o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1285 rows=' rows;
else do; set t1285o; if not missing(actual) and abs(actual-(12))<=1e-10*max(1,abs(12)) then put 'ROUND3_PASS=T1285';
else put 'ERROR: ROUND3_FAIL=T1285 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1285:; quit;
