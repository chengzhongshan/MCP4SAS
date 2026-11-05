/* K4404 sql_any_subquery_boundary, N=5; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data k4404a; do x=1 to 5+1; output; end; run; data k4404b; do y=1 to 5; output; end; run;
proc sql; create table k4404c as select x from k4404a where x>any(select y from k4404b);
create table k4404o as select count(*) as actual from k4404c; quit;

data _null_; if 0 then set k4404o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4404 rows=' rows;
else do; set k4404o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND10_PASS=K4404';
else put 'ERROR: ROUND10_FAIL=K4404 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4404:; quit;
