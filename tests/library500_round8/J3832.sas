/* J3832 sql_union_corresponding_columns, N=3; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:1045 */

data j3832a; x=3; y=100; run;
data j3832b; y=200; x=4; run;
proc sql; create table j3832c as select x,y from j3832a union corr select y,x from j3832b;
create table j3832o as select sum(x) as actual from j3832c; quit;

data _null_; if 0 then set j3832o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3832 rows=' rows;
else do; set j3832o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND8_PASS=J3832';
else put 'ERROR: ROUND8_FAIL=J3832 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3832:; quit;
