/* K4401 sql_any_subquery_boundary, N=2; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data k4401a; do x=1 to 2+1; output; end; run; data k4401b; do y=1 to 2; output; end; run;
proc sql; create table k4401c as select x from k4401a where x>any(select y from k4401b);
create table k4401o as select count(*) as actual from k4401c; quit;

data _null_; if 0 then set k4401o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4401 rows=' rows;
else do; set k4401o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND10_PASS=K4401';
else put 'ERROR: ROUND10_FAIL=K4401 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4401:; quit;
