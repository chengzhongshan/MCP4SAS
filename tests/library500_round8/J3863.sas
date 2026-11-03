/* J3863 sql_scalar_subquery_sum, N=4; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data j3863a; x=4; run; data j3863b; do y=1 to 4; output; end; run;
proc sql; create table j3863o as select x+(select sum(y) from j3863b) as actual from j3863a; quit;

data _null_; if 0 then set j3863o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3863 rows=' rows;
else do; set j3863o; if not missing(actual) and abs(actual-(14))<=1e-9*max(1,abs(14)) then put 'ROUND8_PASS=J3863';
else put 'ERROR: ROUND8_FAIL=J3863 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3863:; quit;
