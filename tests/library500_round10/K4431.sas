/* K4431 call_missing_clears_retained_values, N=2; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:2244 */

data k4431a; retain old1 old2 99; do j=1 to 2; call missing(old1,old2); score=nmiss(old1,old2); output; old1=j; old2=j; end; run;
proc sql; create table k4431o as select sum(score) as actual from k4431a; quit;

data _null_; if 0 then set k4431o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4431 rows=' rows;
else do; set k4431o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND10_PASS=K4431';
else put 'ERROR: ROUND10_FAIL=K4431 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4431:; quit;
