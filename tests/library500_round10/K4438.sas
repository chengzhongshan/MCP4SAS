/* K4438 call_missing_clears_retained_values, N=9; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:2244 */

data k4438a; retain old1 old2 99; do j=1 to 9; call missing(old1,old2); score=nmiss(old1,old2); output; old1=j; old2=j; end; run;
proc sql; create table k4438o as select sum(score) as actual from k4438a; quit;

data _null_; if 0 then set k4438o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4438 rows=' rows;
else do; set k4438o; if not missing(actual) and abs(actual-(18))<=1e-9*max(1,abs(18)) then put 'ROUND10_PASS=K4438';
else put 'ERROR: ROUND10_FAIL=K4438 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4438:; quit;
