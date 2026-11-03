/* J3826 sql_three_way_cross_join, N=7; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data j3826a; do x=1 to 7; output; end; run;
data j3826b; do y=1 to 2; output; end; run; data j3826c; do z=1 to 3; output; end; run;
proc sql; create table j3826o as select count(*) as actual from j3826a,j3826b,j3826c; quit;

data _null_; if 0 then set j3826o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3826 rows=' rows;
else do; set j3826o; if not missing(actual) and abs(actual-(42))<=1e-9*max(1,abs(42)) then put 'ROUND8_PASS=J3826';
else put 'ERROR: ROUND8_FAIL=J3826 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3826:; quit;
