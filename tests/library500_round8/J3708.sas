/* J3708 do_until_bottom_test, N=9; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:666 */

data j3708o; actual=9; do until(actual>=9); actual=actual+1; end; run;

data _null_; if 0 then set j3708o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3708 rows=' rows;
else do; set j3708o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND8_PASS=J3708';
else put 'ERROR: ROUND8_FAIL=J3708 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3708:; quit;
