/* J3702 do_until_bottom_test, N=3; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:666 */

data j3702o; actual=3; do until(actual>=3); actual=actual+1; end; run;

data _null_; if 0 then set j3702o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3702 rows=' rows;
else do; set j3702o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND8_PASS=J3702';
else put 'ERROR: ROUND8_FAIL=J3702 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3702:; quit;
