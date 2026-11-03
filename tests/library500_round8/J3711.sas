/* J3711 nested_dependent_do_bounds, N=2; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:666 */

data j3711o; actual=0; do i=1 to 2; do j=1 to i; actual=actual+i*j; end; end; run;

data _null_; if 0 then set j3711o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3711 rows=' rows;
else do; set j3711o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND8_PASS=J3711';
else put 'ERROR: ROUND8_FAIL=J3711 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3711:; quit;
