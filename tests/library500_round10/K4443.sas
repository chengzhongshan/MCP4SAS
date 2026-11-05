/* K4443 sum_function_versus_missing_addition, N=4; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:2259 */

data k4443a; do j=1 to 4; x=.; y=j; score=(sum(x,y)=j)+(missing(x+y)); output; end; run;
proc sql; create table k4443o as select sum(score) as actual from k4443a; quit;

data _null_; if 0 then set k4443o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4443 rows=' rows;
else do; set k4443o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND10_PASS=K4443';
else put 'ERROR: ROUND10_FAIL=K4443 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4443:; quit;
