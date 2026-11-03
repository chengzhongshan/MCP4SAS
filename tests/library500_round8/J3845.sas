/* J3845 sql_intersect_all_multiplicity, N=6; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:993 */

data j3845a; do j=1 to 6+2; x=1; output; end; run;
data j3845b; do j=1 to 6; x=1; output; end; run;
proc sql; create table j3845c as select x from j3845a intersect all select x from j3845b;
create table j3845o as select count(*) as actual from j3845c; quit;

data _null_; if 0 then set j3845o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3845 rows=' rows;
else do; set j3845o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND8_PASS=J3845';
else put 'ERROR: ROUND8_FAIL=J3845 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3845:; quit;
