/* K4392 sql_all_subquery_boundary, N=3; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data k4392a; do x=1 to 3+1; output; end; run; data k4392b; do y=1 to 3; output; end; run;
proc sql; create table k4392c as select x from k4392a where x>all(select y from k4392b);
create table k4392o as select sum(x) as actual from k4392c; quit;

data _null_; if 0 then set k4392o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4392 rows=' rows;
else do; set k4392o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND10_PASS=K4392';
else put 'ERROR: ROUND10_FAIL=K4392 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4392:; quit;
