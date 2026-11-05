/* K4393 sql_all_subquery_boundary, N=4; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data k4393a; do x=1 to 4+1; output; end; run; data k4393b; do y=1 to 4; output; end; run;
proc sql; create table k4393c as select x from k4393a where x>all(select y from k4393b);
create table k4393o as select sum(x) as actual from k4393c; quit;

data _null_; if 0 then set k4393o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4393 rows=' rows;
else do; set k4393o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND10_PASS=K4393';
else put 'ERROR: ROUND10_FAIL=K4393 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4393:; quit;
