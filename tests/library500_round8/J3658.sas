/* J3658 array_nonunit_two_dimensions, N=9; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data j3658o; array cells{-1:1,2:3} _temporary_; actual=0;
do i=-1 to 1; do j=2 to 3; cells{i,j}=9+10*i+j; actual=actual+cells{i,j}; end; end; run;

data _null_; if 0 then set j3658o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3658 rows=' rows;
else do; set j3658o; if not missing(actual) and abs(actual-(69))<=1e-9*max(1,abs(69)) then put 'ROUND8_PASS=J3658';
else put 'ERROR: ROUND8_FAIL=J3658 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3658:; quit;
