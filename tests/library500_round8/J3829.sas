/* J3829 sql_three_way_cross_join, N=10; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data j3829a; do x=1 to 10; output; end; run;
data j3829b; do y=1 to 2; output; end; run; data j3829c; do z=1 to 3; output; end; run;
proc sql; create table j3829o as select count(*) as actual from j3829a,j3829b,j3829c; quit;

data _null_; if 0 then set j3829o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3829 rows=' rows;
else do; set j3829o; if not missing(actual) and abs(actual-(60))<=1e-9*max(1,abs(60)) then put 'ROUND8_PASS=J3829';
else put 'ERROR: ROUND8_FAIL=J3829 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3829:; quit;
