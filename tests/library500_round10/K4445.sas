/* K4445 sum_function_versus_missing_addition, N=6; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:2259 */

data k4445a; do j=1 to 6; x=.; y=j; score=(sum(x,y)=j)+(missing(x+y)); output; end; run;
proc sql; create table k4445o as select sum(score) as actual from k4445a; quit;

data _null_; if 0 then set k4445o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4445 rows=' rows;
else do; set k4445o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND10_PASS=K4445';
else put 'ERROR: ROUND10_FAIL=K4445 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4445:; quit;
