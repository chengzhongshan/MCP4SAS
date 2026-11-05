/* K4434 call_missing_clears_retained_values, N=5; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:2244 */

data k4434a; retain old1 old2 99; do j=1 to 5; call missing(old1,old2); score=nmiss(old1,old2); output; old1=j; old2=j; end; run;
proc sql; create table k4434o as select sum(score) as actual from k4434a; quit;

data _null_; if 0 then set k4434o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4434 rows=' rows;
else do; set k4434o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND10_PASS=K4434';
else put 'ERROR: ROUND10_FAIL=K4434 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4434:; quit;
