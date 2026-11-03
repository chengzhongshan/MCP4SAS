/* J3841 sql_intersect_all_multiplicity, N=2; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:993 */

data j3841a; do j=1 to 2+2; x=1; output; end; run;
data j3841b; do j=1 to 2; x=1; output; end; run;
proc sql; create table j3841c as select x from j3841a intersect all select x from j3841b;
create table j3841o as select count(*) as actual from j3841c; quit;

data _null_; if 0 then set j3841o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3841 rows=' rows;
else do; set j3841o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND8_PASS=J3841';
else put 'ERROR: ROUND8_FAIL=J3841 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3841:; quit;
