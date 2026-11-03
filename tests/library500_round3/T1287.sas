/* T1287 sql_view_reexecute, N=8; source: SAS-Useful-Codes/Macros/SAS-macros-master/plotit.sas:4004 */

data t1287a; do x=1 to 8; output; end; run;
proc sql; create view t1287v as select * from t1287a; quit;
data t1287a; do x=1 to 2*8; output; end; run;
proc sql; create table t1287o as select count(*) as actual from t1287v; drop view t1287v; quit;

data _null_; if 0 then set t1287o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1287 rows=' rows;
else do; set t1287o; if not missing(actual) and abs(actual-(16))<=1e-10*max(1,abs(16)) then put 'ROUND3_PASS=T1287';
else put 'ERROR: ROUND3_FAIL=T1287 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1287:; quit;
