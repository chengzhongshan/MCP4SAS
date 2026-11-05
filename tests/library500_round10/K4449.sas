/* K4449 sum_function_versus_missing_addition, N=10; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:2259 */

data k4449a; do j=1 to 10; x=.; y=j; score=(sum(x,y)=j)+(missing(x+y)); output; end; run;
proc sql; create table k4449o as select sum(score) as actual from k4449a; quit;

data _null_; if 0 then set k4449o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4449 rows=' rows;
else do; set k4449o; if not missing(actual) and abs(actual-(20))<=1e-9*max(1,abs(20)) then put 'ROUND10_PASS=K4449';
else put 'ERROR: ROUND10_FAIL=K4449 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4449:; quit;
