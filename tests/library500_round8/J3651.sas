/* J3651 array_nonunit_two_dimensions, N=2; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data j3651o; array cells{-1:1,2:3} _temporary_; actual=0;
do i=-1 to 1; do j=2 to 3; cells{i,j}=2+10*i+j; actual=actual+cells{i,j}; end; end; run;

data _null_; if 0 then set j3651o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3651 rows=' rows;
else do; set j3651o; if not missing(actual) and abs(actual-(27))<=1e-9*max(1,abs(27)) then put 'ROUND8_PASS=J3651';
else put 'ERROR: ROUND8_FAIL=J3651 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3651:; quit;
