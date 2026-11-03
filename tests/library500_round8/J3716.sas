/* J3716 nested_dependent_do_bounds, N=7; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:666 */

data j3716o; actual=0; do i=1 to 7; do j=1 to i; actual=actual+i*j; end; end; run;

data _null_; if 0 then set j3716o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3716 rows=' rows;
else do; set j3716o; if not missing(actual) and abs(actual-(462))<=1e-9*max(1,abs(462)) then put 'ROUND8_PASS=J3716';
else put 'ERROR: ROUND8_FAIL=J3716 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3716:; quit;
