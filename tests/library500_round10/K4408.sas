/* K4408 sql_any_subquery_boundary, N=9; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data k4408a; do x=1 to 9+1; output; end; run; data k4408b; do y=1 to 9; output; end; run;
proc sql; create table k4408c as select x from k4408a where x>any(select y from k4408b);
create table k4408o as select count(*) as actual from k4408c; quit;

data _null_; if 0 then set k4408o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4408 rows=' rows;
else do; set k4408o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND10_PASS=K4408';
else put 'ERROR: ROUND10_FAIL=K4408 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4408:; quit;
