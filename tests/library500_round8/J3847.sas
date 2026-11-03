/* J3847 sql_intersect_all_multiplicity, N=8; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:993 */

data j3847a; do j=1 to 8+2; x=1; output; end; run;
data j3847b; do j=1 to 8; x=1; output; end; run;
proc sql; create table j3847c as select x from j3847a intersect all select x from j3847b;
create table j3847o as select count(*) as actual from j3847c; quit;

data _null_; if 0 then set j3847o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3847 rows=' rows;
else do; set j3847o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND8_PASS=J3847';
else put 'ERROR: ROUND8_FAIL=J3847 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3847:; quit;
