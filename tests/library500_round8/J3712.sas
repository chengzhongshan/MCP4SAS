/* J3712 nested_dependent_do_bounds, N=3; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:666 */

data j3712o; actual=0; do i=1 to 3; do j=1 to i; actual=actual+i*j; end; end; run;

data _null_; if 0 then set j3712o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3712 rows=' rows;
else do; set j3712o; if not missing(actual) and abs(actual-(25))<=1e-9*max(1,abs(25)) then put 'ROUND8_PASS=J3712';
else put 'ERROR: ROUND8_FAIL=J3712 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3712:; quit;
