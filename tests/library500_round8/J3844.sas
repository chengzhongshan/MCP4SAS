/* J3844 sql_intersect_all_multiplicity, N=5; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:993 */

data j3844a; do j=1 to 5+2; x=1; output; end; run;
data j3844b; do j=1 to 5; x=1; output; end; run;
proc sql; create table j3844c as select x from j3844a intersect all select x from j3844b;
create table j3844o as select count(*) as actual from j3844c; quit;

data _null_; if 0 then set j3844o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3844 rows=' rows;
else do; set j3844o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND8_PASS=J3844';
else put 'ERROR: ROUND8_FAIL=J3844 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3844:; quit;
