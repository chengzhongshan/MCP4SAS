/* K4391 sql_all_subquery_boundary, N=2; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data k4391a; do x=1 to 2+1; output; end; run; data k4391b; do y=1 to 2; output; end; run;
proc sql; create table k4391c as select x from k4391a where x>all(select y from k4391b);
create table k4391o as select sum(x) as actual from k4391c; quit;

data _null_; if 0 then set k4391o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4391 rows=' rows;
else do; set k4391o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND10_PASS=K4391';
else put 'ERROR: ROUND10_FAIL=K4391 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4391:; quit;
