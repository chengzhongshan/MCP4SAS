/* J3858 sql_except_all_multiplicity, N=9; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:1010 */

data j3858a; do j=1 to 9+2; x=1; output; end; run;
data j3858b; do j=1 to 9; x=1; output; end; run;
proc sql; create table j3858c as select x from j3858a except all select x from j3858b;
create table j3858o as select count(*) as actual from j3858c; quit;

data _null_; if 0 then set j3858o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3858 rows=' rows;
else do; set j3858o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND8_PASS=J3858';
else put 'ERROR: ROUND8_FAIL=J3858 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3858:; quit;
