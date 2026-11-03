/* J3838 sql_union_corresponding_columns, N=9; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:1045 */

data j3838a; x=9; y=100; run;
data j3838b; y=200; x=10; run;
proc sql; create table j3838c as select x,y from j3838a union corr select y,x from j3838b;
create table j3838o as select sum(x) as actual from j3838c; quit;

data _null_; if 0 then set j3838o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3838 rows=' rows;
else do; set j3838o; if not missing(actual) and abs(actual-(19))<=1e-9*max(1,abs(19)) then put 'ROUND8_PASS=J3838';
else put 'ERROR: ROUND8_FAIL=J3838 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3838:; quit;
