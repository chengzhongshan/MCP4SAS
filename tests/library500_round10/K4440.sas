/* K4440 call_missing_clears_retained_values, N=11; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:2244 */

data k4440a; retain old1 old2 99; do j=1 to 11; call missing(old1,old2); score=nmiss(old1,old2); output; old1=j; old2=j; end; run;
proc sql; create table k4440o as select sum(score) as actual from k4440a; quit;

data _null_; if 0 then set k4440o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4440 rows=' rows;
else do; set k4440o; if not missing(actual) and abs(actual-(22))<=1e-9*max(1,abs(22)) then put 'ROUND10_PASS=K4440';
else put 'ERROR: ROUND10_FAIL=K4440 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4440:; quit;
