/* K4402 sql_any_subquery_boundary, N=3; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data k4402a; do x=1 to 3+1; output; end; run; data k4402b; do y=1 to 3; output; end; run;
proc sql; create table k4402c as select x from k4402a where x>any(select y from k4402b);
create table k4402o as select count(*) as actual from k4402c; quit;

data _null_; if 0 then set k4402o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4402 rows=' rows;
else do; set k4402o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND10_PASS=K4402';
else put 'ERROR: ROUND10_FAIL=K4402 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4402:; quit;
