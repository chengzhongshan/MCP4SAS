/* J3719 nested_dependent_do_bounds, N=10; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:666 */

data j3719o; actual=0; do i=1 to 10; do j=1 to i; actual=actual+i*j; end; end; run;

data _null_; if 0 then set j3719o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3719 rows=' rows;
else do; set j3719o; if not missing(actual) and abs(actual-(1705))<=1e-9*max(1,abs(1705)) then put 'ROUND8_PASS=J3719';
else put 'ERROR: ROUND8_FAIL=J3719 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3719:; quit;
