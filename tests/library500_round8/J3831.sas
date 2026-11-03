/* J3831 sql_union_corresponding_columns, N=2; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:1045 */

data j3831a; x=2; y=100; run;
data j3831b; y=200; x=3; run;
proc sql; create table j3831c as select x,y from j3831a union corr select y,x from j3831b;
create table j3831o as select sum(x) as actual from j3831c; quit;

data _null_; if 0 then set j3831o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3831 rows=' rows;
else do; set j3831o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND8_PASS=J3831';
else put 'ERROR: ROUND8_FAIL=J3831 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3831:; quit;
