/* J3828 sql_three_way_cross_join, N=9; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data j3828a; do x=1 to 9; output; end; run;
data j3828b; do y=1 to 2; output; end; run; data j3828c; do z=1 to 3; output; end; run;
proc sql; create table j3828o as select count(*) as actual from j3828a,j3828b,j3828c; quit;

data _null_; if 0 then set j3828o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3828 rows=' rows;
else do; set j3828o; if not missing(actual) and abs(actual-(54))<=1e-9*max(1,abs(54)) then put 'ROUND8_PASS=J3828';
else put 'ERROR: ROUND8_FAIL=J3828 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3828:; quit;
