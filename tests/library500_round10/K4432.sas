/* K4432 call_missing_clears_retained_values, N=3; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:2244 */

data k4432a; retain old1 old2 99; do j=1 to 3; call missing(old1,old2); score=nmiss(old1,old2); output; old1=j; old2=j; end; run;
proc sql; create table k4432o as select sum(score) as actual from k4432a; quit;

data _null_; if 0 then set k4432o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4432 rows=' rows;
else do; set k4432o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND10_PASS=K4432';
else put 'ERROR: ROUND10_FAIL=K4432 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4432:; quit;
