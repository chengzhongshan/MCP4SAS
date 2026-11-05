/* K4406 sql_any_subquery_boundary, N=7; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data k4406a; do x=1 to 7+1; output; end; run; data k4406b; do y=1 to 7; output; end; run;
proc sql; create table k4406c as select x from k4406a where x>any(select y from k4406b);
create table k4406o as select count(*) as actual from k4406c; quit;

data _null_; if 0 then set k4406o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4406 rows=' rows;
else do; set k4406o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND10_PASS=K4406';
else put 'ERROR: ROUND10_FAIL=K4406 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4406:; quit;
