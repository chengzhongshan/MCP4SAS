/* K4441 sum_function_versus_missing_addition, N=2; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:2259 */

data k4441a; do j=1 to 2; x=.; y=j; score=(sum(x,y)=j)+(missing(x+y)); output; end; run;
proc sql; create table k4441o as select sum(score) as actual from k4441a; quit;

data _null_; if 0 then set k4441o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4441 rows=' rows;
else do; set k4441o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND10_PASS=K4441';
else put 'ERROR: ROUND10_FAIL=K4441 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4441:; quit;
