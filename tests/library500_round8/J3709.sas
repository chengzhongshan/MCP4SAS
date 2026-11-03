/* J3709 do_until_bottom_test, N=10; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:666 */

data j3709o; actual=10; do until(actual>=10); actual=actual+1; end; run;

data _null_; if 0 then set j3709o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3709 rows=' rows;
else do; set j3709o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND8_PASS=J3709';
else put 'ERROR: ROUND8_FAIL=J3709 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3709:; quit;
