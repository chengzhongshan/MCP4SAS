/* J3655 array_nonunit_two_dimensions, N=6; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data j3655o; array cells{-1:1,2:3} _temporary_; actual=0;
do i=-1 to 1; do j=2 to 3; cells{i,j}=6+10*i+j; actual=actual+cells{i,j}; end; end; run;

data _null_; if 0 then set j3655o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3655 rows=' rows;
else do; set j3655o; if not missing(actual) and abs(actual-(51))<=1e-9*max(1,abs(51)) then put 'ROUND8_PASS=J3655';
else put 'ERROR: ROUND8_FAIL=J3655 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3655:; quit;
