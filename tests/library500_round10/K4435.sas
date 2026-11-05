/* K4435 call_missing_clears_retained_values, N=6; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:2244 */

data k4435a; retain old1 old2 99; do j=1 to 6; call missing(old1,old2); score=nmiss(old1,old2); output; old1=j; old2=j; end; run;
proc sql; create table k4435o as select sum(score) as actual from k4435a; quit;

data _null_; if 0 then set k4435o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4435 rows=' rows;
else do; set k4435o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND10_PASS=K4435';
else put 'ERROR: ROUND10_FAIL=K4435 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4435:; quit;
