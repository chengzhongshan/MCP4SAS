/* K4436 call_missing_clears_retained_values, N=7; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:2244 */

data k4436a; retain old1 old2 99; do j=1 to 7; call missing(old1,old2); score=nmiss(old1,old2); output; old1=j; old2=j; end; run;
proc sql; create table k4436o as select sum(score) as actual from k4436a; quit;

data _null_; if 0 then set k4436o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4436 rows=' rows;
else do; set k4436o; if not missing(actual) and abs(actual-(14))<=1e-9*max(1,abs(14)) then put 'ROUND10_PASS=K4436';
else put 'ERROR: ROUND10_FAIL=K4436 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4436:; quit;
