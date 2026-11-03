/* J3718 nested_dependent_do_bounds, N=9; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:666 */

data j3718o; actual=0; do i=1 to 9; do j=1 to i; actual=actual+i*j; end; end; run;

data _null_; if 0 then set j3718o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3718 rows=' rows;
else do; set j3718o; if not missing(actual) and abs(actual-(1155))<=1e-9*max(1,abs(1155)) then put 'ROUND8_PASS=J3718';
else put 'ERROR: ROUND8_FAIL=J3718 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3718:; quit;
