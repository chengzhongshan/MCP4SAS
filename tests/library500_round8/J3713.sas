/* J3713 nested_dependent_do_bounds, N=4; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:666 */

data j3713o; actual=0; do i=1 to 4; do j=1 to i; actual=actual+i*j; end; end; run;

data _null_; if 0 then set j3713o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3713 rows=' rows;
else do; set j3713o; if not missing(actual) and abs(actual-(65))<=1e-9*max(1,abs(65)) then put 'ROUND8_PASS=J3713';
else put 'ERROR: ROUND8_FAIL=J3713 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3713:; quit;
