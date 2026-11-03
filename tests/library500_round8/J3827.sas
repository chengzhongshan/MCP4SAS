/* J3827 sql_three_way_cross_join, N=8; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data j3827a; do x=1 to 8; output; end; run;
data j3827b; do y=1 to 2; output; end; run; data j3827c; do z=1 to 3; output; end; run;
proc sql; create table j3827o as select count(*) as actual from j3827a,j3827b,j3827c; quit;

data _null_; if 0 then set j3827o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3827 rows=' rows;
else do; set j3827o; if not missing(actual) and abs(actual-(48))<=1e-9*max(1,abs(48)) then put 'ROUND8_PASS=J3827';
else put 'ERROR: ROUND8_FAIL=J3827 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3827:; quit;
