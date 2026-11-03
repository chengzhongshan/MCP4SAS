/* J3830 sql_three_way_cross_join, N=11; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data j3830a; do x=1 to 11; output; end; run;
data j3830b; do y=1 to 2; output; end; run; data j3830c; do z=1 to 3; output; end; run;
proc sql; create table j3830o as select count(*) as actual from j3830a,j3830b,j3830c; quit;

data _null_; if 0 then set j3830o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3830 rows=' rows;
else do; set j3830o; if not missing(actual) and abs(actual-(66))<=1e-9*max(1,abs(66)) then put 'ROUND8_PASS=J3830';
else put 'ERROR: ROUND8_FAIL=J3830 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3830:; quit;
