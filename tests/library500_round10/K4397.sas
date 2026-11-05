/* K4397 sql_all_subquery_boundary, N=8; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data k4397a; do x=1 to 8+1; output; end; run; data k4397b; do y=1 to 8; output; end; run;
proc sql; create table k4397c as select x from k4397a where x>all(select y from k4397b);
create table k4397o as select sum(x) as actual from k4397c; quit;

data _null_; if 0 then set k4397o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4397 rows=' rows;
else do; set k4397o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND10_PASS=K4397';
else put 'ERROR: ROUND10_FAIL=K4397 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4397:; quit;
