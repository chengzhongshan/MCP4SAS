/* K4429 special_missing_relational_order, N=10; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:41 */

data k4429a; do j=1 to 10; x=.A; score=(x>. and x<0); output; end; run;
proc sql; create table k4429o as select sum(score) as actual from k4429a; quit;

data _null_; if 0 then set k4429o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4429 rows=' rows;
else do; set k4429o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND10_PASS=K4429';
else put 'ERROR: ROUND10_FAIL=K4429 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4429:; quit;
