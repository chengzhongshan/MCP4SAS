/* K4450 sum_function_versus_missing_addition, N=11; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:2259 */

data k4450a; do j=1 to 11; x=.; y=j; score=(sum(x,y)=j)+(missing(x+y)); output; end; run;
proc sql; create table k4450o as select sum(score) as actual from k4450a; quit;

data _null_; if 0 then set k4450o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4450 rows=' rows;
else do; set k4450o; if not missing(actual) and abs(actual-(22))<=1e-9*max(1,abs(22)) then put 'ROUND10_PASS=K4450';
else put 'ERROR: ROUND10_FAIL=K4450 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4450:; quit;
