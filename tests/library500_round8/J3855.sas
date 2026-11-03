/* J3855 sql_except_all_multiplicity, N=6; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:1010 */

data j3855a; do j=1 to 6+2; x=1; output; end; run;
data j3855b; do j=1 to 6; x=1; output; end; run;
proc sql; create table j3855c as select x from j3855a except all select x from j3855b;
create table j3855o as select count(*) as actual from j3855c; quit;

data _null_; if 0 then set j3855o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3855 rows=' rows;
else do; set j3855o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND8_PASS=J3855';
else put 'ERROR: ROUND8_FAIL=J3855 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3855:; quit;
