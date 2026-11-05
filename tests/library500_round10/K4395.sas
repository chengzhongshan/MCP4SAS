/* K4395 sql_all_subquery_boundary, N=6; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data k4395a; do x=1 to 6+1; output; end; run; data k4395b; do y=1 to 6; output; end; run;
proc sql; create table k4395c as select x from k4395a where x>all(select y from k4395b);
create table k4395o as select sum(x) as actual from k4395c; quit;

data _null_; if 0 then set k4395o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4395 rows=' rows;
else do; set k4395o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND10_PASS=K4395';
else put 'ERROR: ROUND10_FAIL=K4395 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4395:; quit;
