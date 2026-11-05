/* K4423 special_missing_relational_order, N=4; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:41 */

data k4423a; do j=1 to 4; x=.A; score=(x>. and x<0); output; end; run;
proc sql; create table k4423o as select sum(score) as actual from k4423a; quit;

data _null_; if 0 then set k4423o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4423 rows=' rows;
else do; set k4423o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND10_PASS=K4423';
else put 'ERROR: ROUND10_FAIL=K4423 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4423:; quit;
