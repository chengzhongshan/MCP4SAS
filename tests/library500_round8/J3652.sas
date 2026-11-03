/* J3652 array_nonunit_two_dimensions, N=3; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data j3652o; array cells{-1:1,2:3} _temporary_; actual=0;
do i=-1 to 1; do j=2 to 3; cells{i,j}=3+10*i+j; actual=actual+cells{i,j}; end; end; run;

data _null_; if 0 then set j3652o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3652 rows=' rows;
else do; set j3652o; if not missing(actual) and abs(actual-(33))<=1e-9*max(1,abs(33)) then put 'ROUND8_PASS=J3652';
else put 'ERROR: ROUND8_FAIL=J3652 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3652:; quit;
