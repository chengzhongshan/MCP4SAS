/* J3714 nested_dependent_do_bounds, N=5; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:666 */

data j3714o; actual=0; do i=1 to 5; do j=1 to i; actual=actual+i*j; end; end; run;

data _null_; if 0 then set j3714o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3714 rows=' rows;
else do; set j3714o; if not missing(actual) and abs(actual-(140))<=1e-9*max(1,abs(140)) then put 'ROUND8_PASS=J3714';
else put 'ERROR: ROUND8_FAIL=J3714 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3714:; quit;
