/* J3822 sql_three_way_cross_join, N=3; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data j3822a; do x=1 to 3; output; end; run;
data j3822b; do y=1 to 2; output; end; run; data j3822c; do z=1 to 3; output; end; run;
proc sql; create table j3822o as select count(*) as actual from j3822a,j3822b,j3822c; quit;

data _null_; if 0 then set j3822o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3822 rows=' rows;
else do; set j3822o; if not missing(actual) and abs(actual-(18))<=1e-9*max(1,abs(18)) then put 'ROUND8_PASS=J3822';
else put 'ERROR: ROUND8_FAIL=J3822 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3822:; quit;
