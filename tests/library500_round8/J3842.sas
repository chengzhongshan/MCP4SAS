/* J3842 sql_intersect_all_multiplicity, N=3; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:993 */

data j3842a; do j=1 to 3+2; x=1; output; end; run;
data j3842b; do j=1 to 3; x=1; output; end; run;
proc sql; create table j3842c as select x from j3842a intersect all select x from j3842b;
create table j3842o as select count(*) as actual from j3842c; quit;

data _null_; if 0 then set j3842o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3842 rows=' rows;
else do; set j3842o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND8_PASS=J3842';
else put 'ERROR: ROUND8_FAIL=J3842 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3842:; quit;
