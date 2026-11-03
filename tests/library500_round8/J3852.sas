/* J3852 sql_except_all_multiplicity, N=3; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:1010 */

data j3852a; do j=1 to 3+2; x=1; output; end; run;
data j3852b; do j=1 to 3; x=1; output; end; run;
proc sql; create table j3852c as select x from j3852a except all select x from j3852b;
create table j3852o as select count(*) as actual from j3852c; quit;

data _null_; if 0 then set j3852o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3852 rows=' rows;
else do; set j3852o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND8_PASS=J3852';
else put 'ERROR: ROUND8_FAIL=J3852 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3852:; quit;
