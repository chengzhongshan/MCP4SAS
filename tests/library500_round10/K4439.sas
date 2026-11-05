/* K4439 call_missing_clears_retained_values, N=10; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:2244 */

data k4439a; retain old1 old2 99; do j=1 to 10; call missing(old1,old2); score=nmiss(old1,old2); output; old1=j; old2=j; end; run;
proc sql; create table k4439o as select sum(score) as actual from k4439a; quit;

data _null_; if 0 then set k4439o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4439 rows=' rows;
else do; set k4439o; if not missing(actual) and abs(actual-(20))<=1e-9*max(1,abs(20)) then put 'ROUND10_PASS=K4439';
else put 'ERROR: ROUND10_FAIL=K4439 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4439:; quit;
