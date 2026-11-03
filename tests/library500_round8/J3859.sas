/* J3859 sql_except_all_multiplicity, N=10; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:1010 */

data j3859a; do j=1 to 10+2; x=1; output; end; run;
data j3859b; do j=1 to 10; x=1; output; end; run;
proc sql; create table j3859c as select x from j3859a except all select x from j3859b;
create table j3859o as select count(*) as actual from j3859c; quit;

data _null_; if 0 then set j3859o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3859 rows=' rows;
else do; set j3859o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND8_PASS=J3859';
else put 'ERROR: ROUND8_FAIL=J3859 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3859:; quit;
