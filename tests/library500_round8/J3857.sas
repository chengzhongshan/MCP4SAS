/* J3857 sql_except_all_multiplicity, N=8; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:1010 */

data j3857a; do j=1 to 8+2; x=1; output; end; run;
data j3857b; do j=1 to 8; x=1; output; end; run;
proc sql; create table j3857c as select x from j3857a except all select x from j3857b;
create table j3857o as select count(*) as actual from j3857c; quit;

data _null_; if 0 then set j3857o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3857 rows=' rows;
else do; set j3857o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND8_PASS=J3857';
else put 'ERROR: ROUND8_FAIL=J3857 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3857:; quit;
