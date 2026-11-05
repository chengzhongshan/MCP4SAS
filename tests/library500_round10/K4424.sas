/* K4424 special_missing_relational_order, N=5; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:41 */

data k4424a; do j=1 to 5; x=.A; score=(x>. and x<0); output; end; run;
proc sql; create table k4424o as select sum(score) as actual from k4424a; quit;

data _null_; if 0 then set k4424o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4424 rows=' rows;
else do; set k4424o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND10_PASS=K4424';
else put 'ERROR: ROUND10_FAIL=K4424 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4424:; quit;
