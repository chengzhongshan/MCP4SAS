/* J3824 sql_three_way_cross_join, N=5; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data j3824a; do x=1 to 5; output; end; run;
data j3824b; do y=1 to 2; output; end; run; data j3824c; do z=1 to 3; output; end; run;
proc sql; create table j3824o as select count(*) as actual from j3824a,j3824b,j3824c; quit;

data _null_; if 0 then set j3824o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3824 rows=' rows;
else do; set j3824o; if not missing(actual) and abs(actual-(30))<=1e-9*max(1,abs(30)) then put 'ROUND8_PASS=J3824';
else put 'ERROR: ROUND8_FAIL=J3824 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3824:; quit;
