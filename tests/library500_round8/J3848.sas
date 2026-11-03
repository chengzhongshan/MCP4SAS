/* J3848 sql_intersect_all_multiplicity, N=9; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:993 */

data j3848a; do j=1 to 9+2; x=1; output; end; run;
data j3848b; do j=1 to 9; x=1; output; end; run;
proc sql; create table j3848c as select x from j3848a intersect all select x from j3848b;
create table j3848o as select count(*) as actual from j3848c; quit;

data _null_; if 0 then set j3848o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3848 rows=' rows;
else do; set j3848o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND8_PASS=J3848';
else put 'ERROR: ROUND8_FAIL=J3848 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3848:; quit;
