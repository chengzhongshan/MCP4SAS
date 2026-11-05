/* K4421 special_missing_relational_order, N=2; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:41 */

data k4421a; do j=1 to 2; x=.A; score=(x>. and x<0); output; end; run;
proc sql; create table k4421o as select sum(score) as actual from k4421a; quit;

data _null_; if 0 then set k4421o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4421 rows=' rows;
else do; set k4421o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND10_PASS=K4421';
else put 'ERROR: ROUND10_FAIL=K4421 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4421:; quit;
