/* J3703 do_until_bottom_test, N=4; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:666 */

data j3703o; actual=4; do until(actual>=4); actual=actual+1; end; run;

data _null_; if 0 then set j3703o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3703 rows=' rows;
else do; set j3703o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND8_PASS=J3703';
else put 'ERROR: ROUND8_FAIL=J3703 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3703:; quit;
