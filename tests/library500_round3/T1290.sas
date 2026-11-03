/* T1290 sql_view_reexecute, N=11; source: SAS-Useful-Codes/Macros/SAS-macros-master/plotit.sas:4004 */

data t1290a; do x=1 to 11; output; end; run;
proc sql; create view t1290v as select * from t1290a; quit;
data t1290a; do x=1 to 2*11; output; end; run;
proc sql; create table t1290o as select count(*) as actual from t1290v; drop view t1290v; quit;

data _null_; if 0 then set t1290o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1290 rows=' rows;
else do; set t1290o; if not missing(actual) and abs(actual-(22))<=1e-10*max(1,abs(22)) then put 'ROUND3_PASS=T1290';
else put 'ERROR: ROUND3_FAIL=T1290 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1290:; quit;
