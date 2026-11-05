/* K4398 sql_all_subquery_boundary, N=9; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data k4398a; do x=1 to 9+1; output; end; run; data k4398b; do y=1 to 9; output; end; run;
proc sql; create table k4398c as select x from k4398a where x>all(select y from k4398b);
create table k4398o as select sum(x) as actual from k4398c; quit;

data _null_; if 0 then set k4398o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4398 rows=' rows;
else do; set k4398o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND10_PASS=K4398';
else put 'ERROR: ROUND10_FAIL=K4398 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4398:; quit;
