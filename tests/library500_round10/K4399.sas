/* K4399 sql_all_subquery_boundary, N=10; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data k4399a; do x=1 to 10+1; output; end; run; data k4399b; do y=1 to 10; output; end; run;
proc sql; create table k4399c as select x from k4399a where x>all(select y from k4399b);
create table k4399o as select sum(x) as actual from k4399c; quit;

data _null_; if 0 then set k4399o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4399 rows=' rows;
else do; set k4399o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND10_PASS=K4399';
else put 'ERROR: ROUND10_FAIL=K4399 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4399:; quit;
