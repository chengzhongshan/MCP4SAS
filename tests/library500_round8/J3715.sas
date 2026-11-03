/* J3715 nested_dependent_do_bounds, N=6; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:666 */

data j3715o; actual=0; do i=1 to 6; do j=1 to i; actual=actual+i*j; end; end; run;

data _null_; if 0 then set j3715o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3715 rows=' rows;
else do; set j3715o; if not missing(actual) and abs(actual-(266))<=1e-9*max(1,abs(266)) then put 'ROUND8_PASS=J3715';
else put 'ERROR: ROUND8_FAIL=J3715 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3715:; quit;
