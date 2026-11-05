/* K4442 sum_function_versus_missing_addition, N=3; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:2259 */

data k4442a; do j=1 to 3; x=.; y=j; score=(sum(x,y)=j)+(missing(x+y)); output; end; run;
proc sql; create table k4442o as select sum(score) as actual from k4442a; quit;

data _null_; if 0 then set k4442o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4442 rows=' rows;
else do; set k4442o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND10_PASS=K4442';
else put 'ERROR: ROUND10_FAIL=K4442 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4442:; quit;
