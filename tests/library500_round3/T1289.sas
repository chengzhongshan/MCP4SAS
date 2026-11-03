/* T1289 sql_view_reexecute, N=10; source: SAS-Useful-Codes/Macros/SAS-macros-master/plotit.sas:4004 */

data t1289a; do x=1 to 10; output; end; run;
proc sql; create view t1289v as select * from t1289a; quit;
data t1289a; do x=1 to 2*10; output; end; run;
proc sql; create table t1289o as select count(*) as actual from t1289v; drop view t1289v; quit;

data _null_; if 0 then set t1289o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1289 rows=' rows;
else do; set t1289o; if not missing(actual) and abs(actual-(20))<=1e-10*max(1,abs(20)) then put 'ROUND3_PASS=T1289';
else put 'ERROR: ROUND3_FAIL=T1289 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1289:; quit;
