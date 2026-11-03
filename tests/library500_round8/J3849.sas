/* J3849 sql_intersect_all_multiplicity, N=10; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:993 */

data j3849a; do j=1 to 10+2; x=1; output; end; run;
data j3849b; do j=1 to 10; x=1; output; end; run;
proc sql; create table j3849c as select x from j3849a intersect all select x from j3849b;
create table j3849o as select count(*) as actual from j3849c; quit;

data _null_; if 0 then set j3849o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3849 rows=' rows;
else do; set j3849o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND8_PASS=J3849';
else put 'ERROR: ROUND8_FAIL=J3849 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3849:; quit;
