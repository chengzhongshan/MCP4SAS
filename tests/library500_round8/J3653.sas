/* J3653 array_nonunit_two_dimensions, N=4; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data j3653o; array cells{-1:1,2:3} _temporary_; actual=0;
do i=-1 to 1; do j=2 to 3; cells{i,j}=4+10*i+j; actual=actual+cells{i,j}; end; end; run;

data _null_; if 0 then set j3653o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3653 rows=' rows;
else do; set j3653o; if not missing(actual) and abs(actual-(39))<=1e-9*max(1,abs(39)) then put 'ROUND8_PASS=J3653';
else put 'ERROR: ROUND8_FAIL=J3653 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3653:; quit;
