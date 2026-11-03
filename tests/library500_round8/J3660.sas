/* J3660 array_nonunit_two_dimensions, N=11; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data j3660o; array cells{-1:1,2:3} _temporary_; actual=0;
do i=-1 to 1; do j=2 to 3; cells{i,j}=11+10*i+j; actual=actual+cells{i,j}; end; end; run;

data _null_; if 0 then set j3660o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3660 rows=' rows;
else do; set j3660o; if not missing(actual) and abs(actual-(81))<=1e-9*max(1,abs(81)) then put 'ROUND8_PASS=J3660';
else put 'ERROR: ROUND8_FAIL=J3660 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3660:; quit;
