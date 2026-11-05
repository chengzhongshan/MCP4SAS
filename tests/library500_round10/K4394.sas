/* K4394 sql_all_subquery_boundary, N=5; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data k4394a; do x=1 to 5+1; output; end; run; data k4394b; do y=1 to 5; output; end; run;
proc sql; create table k4394c as select x from k4394a where x>all(select y from k4394b);
create table k4394o as select sum(x) as actual from k4394c; quit;

data _null_; if 0 then set k4394o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4394 rows=' rows;
else do; set k4394o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND10_PASS=K4394';
else put 'ERROR: ROUND10_FAIL=K4394 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4394:; quit;
