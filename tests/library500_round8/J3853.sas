/* J3853 sql_except_all_multiplicity, N=4; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:1010 */

data j3853a; do j=1 to 4+2; x=1; output; end; run;
data j3853b; do j=1 to 4; x=1; output; end; run;
proc sql; create table j3853c as select x from j3853a except all select x from j3853b;
create table j3853o as select count(*) as actual from j3853c; quit;

data _null_; if 0 then set j3853o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3853 rows=' rows;
else do; set j3853o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND8_PASS=J3853';
else put 'ERROR: ROUND8_FAIL=J3853 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3853:; quit;
