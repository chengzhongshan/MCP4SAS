/* J3851 sql_except_all_multiplicity, N=2; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:1010 */

data j3851a; do j=1 to 2+2; x=1; output; end; run;
data j3851b; do j=1 to 2; x=1; output; end; run;
proc sql; create table j3851c as select x from j3851a except all select x from j3851b;
create table j3851o as select count(*) as actual from j3851c; quit;

data _null_; if 0 then set j3851o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3851 rows=' rows;
else do; set j3851o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND8_PASS=J3851';
else put 'ERROR: ROUND8_FAIL=J3851 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3851:; quit;
