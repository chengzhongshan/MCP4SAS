/* J3705 do_until_bottom_test, N=6; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:666 */

data j3705o; actual=6; do until(actual>=6); actual=actual+1; end; run;

data _null_; if 0 then set j3705o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3705 rows=' rows;
else do; set j3705o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND8_PASS=J3705';
else put 'ERROR: ROUND8_FAIL=J3705 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3705:; quit;
