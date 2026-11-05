/* K4400 sql_all_subquery_boundary, N=11; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data k4400a; do x=1 to 11+1; output; end; run; data k4400b; do y=1 to 11; output; end; run;
proc sql; create table k4400c as select x from k4400a where x>all(select y from k4400b);
create table k4400o as select sum(x) as actual from k4400c; quit;

data _null_; if 0 then set k4400o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4400 rows=' rows;
else do; set k4400o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND10_PASS=K4400';
else put 'ERROR: ROUND10_FAIL=K4400 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4400:; quit;
