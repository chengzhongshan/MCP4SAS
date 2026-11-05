/* K4409 sql_any_subquery_boundary, N=10; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data k4409a; do x=1 to 10+1; output; end; run; data k4409b; do y=1 to 10; output; end; run;
proc sql; create table k4409c as select x from k4409a where x>any(select y from k4409b);
create table k4409o as select count(*) as actual from k4409c; quit;

data _null_; if 0 then set k4409o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4409 rows=' rows;
else do; set k4409o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND10_PASS=K4409';
else put 'ERROR: ROUND10_FAIL=K4409 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4409:; quit;
