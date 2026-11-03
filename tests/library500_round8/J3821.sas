/* J3821 sql_three_way_cross_join, N=2; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data j3821a; do x=1 to 2; output; end; run;
data j3821b; do y=1 to 2; output; end; run; data j3821c; do z=1 to 3; output; end; run;
proc sql; create table j3821o as select count(*) as actual from j3821a,j3821b,j3821c; quit;

data _null_; if 0 then set j3821o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3821 rows=' rows;
else do; set j3821o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND8_PASS=J3821';
else put 'ERROR: ROUND8_FAIL=J3821 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3821:; quit;
