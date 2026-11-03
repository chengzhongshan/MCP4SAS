/* J3856 sql_except_all_multiplicity, N=7; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:1010 */

data j3856a; do j=1 to 7+2; x=1; output; end; run;
data j3856b; do j=1 to 7; x=1; output; end; run;
proc sql; create table j3856c as select x from j3856a except all select x from j3856b;
create table j3856o as select count(*) as actual from j3856c; quit;

data _null_; if 0 then set j3856o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3856 rows=' rows;
else do; set j3856o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND8_PASS=J3856';
else put 'ERROR: ROUND8_FAIL=J3856 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3856:; quit;
