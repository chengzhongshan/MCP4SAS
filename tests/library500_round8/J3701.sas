/* J3701 do_until_bottom_test, N=2; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:666 */

data j3701o; actual=2; do until(actual>=2); actual=actual+1; end; run;

data _null_; if 0 then set j3701o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3701 rows=' rows;
else do; set j3701o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND8_PASS=J3701';
else put 'ERROR: ROUND8_FAIL=J3701 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3701:; quit;
