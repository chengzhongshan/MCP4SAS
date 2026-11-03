/* J3836 sql_union_corresponding_columns, N=7; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:1045 */

data j3836a; x=7; y=100; run;
data j3836b; y=200; x=8; run;
proc sql; create table j3836c as select x,y from j3836a union corr select y,x from j3836b;
create table j3836o as select sum(x) as actual from j3836c; quit;

data _null_; if 0 then set j3836o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3836 rows=' rows;
else do; set j3836o; if not missing(actual) and abs(actual-(15))<=1e-9*max(1,abs(15)) then put 'ROUND8_PASS=J3836';
else put 'ERROR: ROUND8_FAIL=J3836 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3836:; quit;
