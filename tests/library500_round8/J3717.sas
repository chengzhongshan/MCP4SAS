/* J3717 nested_dependent_do_bounds, N=8; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:666 */

data j3717o; actual=0; do i=1 to 8; do j=1 to i; actual=actual+i*j; end; end; run;

data _null_; if 0 then set j3717o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3717 rows=' rows;
else do; set j3717o; if not missing(actual) and abs(actual-(750))<=1e-9*max(1,abs(750)) then put 'ROUND8_PASS=J3717';
else put 'ERROR: ROUND8_FAIL=J3717 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3717:; quit;
