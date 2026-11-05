/* K4410 sql_any_subquery_boundary, N=11; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data k4410a; do x=1 to 11+1; output; end; run; data k4410b; do y=1 to 11; output; end; run;
proc sql; create table k4410c as select x from k4410a where x>any(select y from k4410b);
create table k4410o as select count(*) as actual from k4410c; quit;

data _null_; if 0 then set k4410o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4410 rows=' rows;
else do; set k4410o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND10_PASS=K4410';
else put 'ERROR: ROUND10_FAIL=K4410 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4410:; quit;
