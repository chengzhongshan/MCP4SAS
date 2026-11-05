/* K4447 sum_function_versus_missing_addition, N=8; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:2259 */

data k4447a; do j=1 to 8; x=.; y=j; score=(sum(x,y)=j)+(missing(x+y)); output; end; run;
proc sql; create table k4447o as select sum(score) as actual from k4447a; quit;

data _null_; if 0 then set k4447o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4447 rows=' rows;
else do; set k4447o; if not missing(actual) and abs(actual-(16))<=1e-9*max(1,abs(16)) then put 'ROUND10_PASS=K4447';
else put 'ERROR: ROUND10_FAIL=K4447 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4447:; quit;
