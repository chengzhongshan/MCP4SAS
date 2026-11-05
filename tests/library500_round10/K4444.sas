/* K4444 sum_function_versus_missing_addition, N=5; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:2259 */

data k4444a; do j=1 to 5; x=.; y=j; score=(sum(x,y)=j)+(missing(x+y)); output; end; run;
proc sql; create table k4444o as select sum(score) as actual from k4444a; quit;

data _null_; if 0 then set k4444o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4444 rows=' rows;
else do; set k4444o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND10_PASS=K4444';
else put 'ERROR: ROUND10_FAIL=K4444 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4444:; quit;
