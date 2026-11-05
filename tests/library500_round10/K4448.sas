/* K4448 sum_function_versus_missing_addition, N=9; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:2259 */

data k4448a; do j=1 to 9; x=.; y=j; score=(sum(x,y)=j)+(missing(x+y)); output; end; run;
proc sql; create table k4448o as select sum(score) as actual from k4448a; quit;

data _null_; if 0 then set k4448o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4448 rows=' rows;
else do; set k4448o; if not missing(actual) and abs(actual-(18))<=1e-9*max(1,abs(18)) then put 'ROUND10_PASS=K4448';
else put 'ERROR: ROUND10_FAIL=K4448 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4448:; quit;
