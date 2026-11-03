/* T1283 sql_view_reexecute, N=4; source: SAS-Useful-Codes/Macros/SAS-macros-master/plotit.sas:4004 */

data t1283a; do x=1 to 4; output; end; run;
proc sql; create view t1283v as select * from t1283a; quit;
data t1283a; do x=1 to 2*4; output; end; run;
proc sql; create table t1283o as select count(*) as actual from t1283v; drop view t1283v; quit;

data _null_; if 0 then set t1283o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1283 rows=' rows;
else do; set t1283o; if not missing(actual) and abs(actual-(8))<=1e-10*max(1,abs(8)) then put 'ROUND3_PASS=T1283';
else put 'ERROR: ROUND3_FAIL=T1283 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1283:; quit;
