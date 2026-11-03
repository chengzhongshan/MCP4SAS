/* J3720 nested_dependent_do_bounds, N=11; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:666 */

data j3720o; actual=0; do i=1 to 11; do j=1 to i; actual=actual+i*j; end; end; run;

data _null_; if 0 then set j3720o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3720 rows=' rows;
else do; set j3720o; if not missing(actual) and abs(actual-(2431))<=1e-9*max(1,abs(2431)) then put 'ROUND8_PASS=J3720';
else put 'ERROR: ROUND8_FAIL=J3720 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3720:; quit;
