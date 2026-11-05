/* K4446 sum_function_versus_missing_addition, N=7; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:2259 */

data k4446a; do j=1 to 7; x=.; y=j; score=(sum(x,y)=j)+(missing(x+y)); output; end; run;
proc sql; create table k4446o as select sum(score) as actual from k4446a; quit;

data _null_; if 0 then set k4446o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4446 rows=' rows;
else do; set k4446o; if not missing(actual) and abs(actual-(14))<=1e-9*max(1,abs(14)) then put 'ROUND10_PASS=K4446';
else put 'ERROR: ROUND10_FAIL=K4446 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4446:; quit;
