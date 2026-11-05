/* K4403 sql_any_subquery_boundary, N=4; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data k4403a; do x=1 to 4+1; output; end; run; data k4403b; do y=1 to 4; output; end; run;
proc sql; create table k4403c as select x from k4403a where x>any(select y from k4403b);
create table k4403o as select count(*) as actual from k4403c; quit;

data _null_; if 0 then set k4403o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4403 rows=' rows;
else do; set k4403o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND10_PASS=K4403';
else put 'ERROR: ROUND10_FAIL=K4403 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4403:; quit;
