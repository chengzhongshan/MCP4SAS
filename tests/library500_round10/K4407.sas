/* K4407 sql_any_subquery_boundary, N=8; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data k4407a; do x=1 to 8+1; output; end; run; data k4407b; do y=1 to 8; output; end; run;
proc sql; create table k4407c as select x from k4407a where x>any(select y from k4407b);
create table k4407o as select count(*) as actual from k4407c; quit;

data _null_; if 0 then set k4407o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4407 rows=' rows;
else do; set k4407o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND10_PASS=K4407';
else put 'ERROR: ROUND10_FAIL=K4407 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4407:; quit;
