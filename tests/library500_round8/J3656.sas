/* J3656 array_nonunit_two_dimensions, N=7; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data j3656o; array cells{-1:1,2:3} _temporary_; actual=0;
do i=-1 to 1; do j=2 to 3; cells{i,j}=7+10*i+j; actual=actual+cells{i,j}; end; end; run;

data _null_; if 0 then set j3656o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3656 rows=' rows;
else do; set j3656o; if not missing(actual) and abs(actual-(57))<=1e-9*max(1,abs(57)) then put 'ROUND8_PASS=J3656';
else put 'ERROR: ROUND8_FAIL=J3656 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3656:; quit;
