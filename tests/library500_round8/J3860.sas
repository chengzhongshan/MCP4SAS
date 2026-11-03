/* J3860 sql_except_all_multiplicity, N=11; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:1010 */

data j3860a; do j=1 to 11+2; x=1; output; end; run;
data j3860b; do j=1 to 11; x=1; output; end; run;
proc sql; create table j3860c as select x from j3860a except all select x from j3860b;
create table j3860o as select count(*) as actual from j3860c; quit;

data _null_; if 0 then set j3860o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3860 rows=' rows;
else do; set j3860o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND8_PASS=J3860';
else put 'ERROR: ROUND8_FAIL=J3860 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3860:; quit;
