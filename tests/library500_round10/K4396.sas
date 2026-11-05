/* K4396 sql_all_subquery_boundary, N=7; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data k4396a; do x=1 to 7+1; output; end; run; data k4396b; do y=1 to 7; output; end; run;
proc sql; create table k4396c as select x from k4396a where x>all(select y from k4396b);
create table k4396o as select sum(x) as actual from k4396c; quit;

data _null_; if 0 then set k4396o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4396 rows=' rows;
else do; set k4396o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND10_PASS=K4396';
else put 'ERROR: ROUND10_FAIL=K4396 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4396:; quit;
