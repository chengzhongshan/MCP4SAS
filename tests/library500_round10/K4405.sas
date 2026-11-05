/* K4405 sql_any_subquery_boundary, N=6; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data k4405a; do x=1 to 6+1; output; end; run; data k4405b; do y=1 to 6; output; end; run;
proc sql; create table k4405c as select x from k4405a where x>any(select y from k4405b);
create table k4405o as select count(*) as actual from k4405c; quit;

data _null_; if 0 then set k4405o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4405 rows=' rows;
else do; set k4405o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND10_PASS=K4405';
else put 'ERROR: ROUND10_FAIL=K4405 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4405:; quit;
