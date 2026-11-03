/* J3840 sql_union_corresponding_columns, N=11; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:1045 */

data j3840a; x=11; y=100; run;
data j3840b; y=200; x=12; run;
proc sql; create table j3840c as select x,y from j3840a union corr select y,x from j3840b;
create table j3840o as select sum(x) as actual from j3840c; quit;

data _null_; if 0 then set j3840o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3840 rows=' rows;
else do; set j3840o; if not missing(actual) and abs(actual-(23))<=1e-9*max(1,abs(23)) then put 'ROUND8_PASS=J3840';
else put 'ERROR: ROUND8_FAIL=J3840 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3840:; quit;
